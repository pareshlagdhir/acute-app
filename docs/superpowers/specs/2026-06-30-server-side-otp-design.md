# Server-side OTP via MSG91 v5 REST API

**Date:** 2026-06-30
**Status:** Approved (design)

## Problem

OTP send/verify currently runs **client-side** in the Flutter app through the
`sendotp_flutter_sdk` MSG91 widget. The widget path has been flaky (templateId /
authkey issues; the backend code carries diagnostic logging and comments about
OTPs staying "unverified"). The backend only validates the resulting widget
access-token via `POST /api/v5/widget/verifyAccessToken`.

The MSG91 **v5 OTP REST API** has been verified working from the MSG91 portal
(OTP delivered to a real handset). Move the entire OTP lifecycle server-side so
the authkey/template never ship in the app binary and there is a single place to
debug.

## Verified MSG91 v5 endpoints

All return **HTTP 200** with a body `{"type": "success"|"error", "message"/"request_id": ...}`.
Mobile must be `<countrycode><10-digit>` — no `+`, no leading `0`.

- **Send:** `POST https://control.msg91.com/api/v5/otp?template_id=&mobile=&authkey=`
  → success carries `request_id` (not needed downstream; verify/retry key off `mobile`).
- **Verify:** `GET https://control.msg91.com/api/v5/otp/verify?otp=&mobile=`, header `authkey:`.
- **Retry:** `GET https://control.msg91.com/api/v5/otp/retry?authkey=&retrytype=&mobile=`
  (`retrytype` = `text` | `voice`).

## Decisions

- **Verify merges with login.** `POST /otp/verify` checks the OTP *and*, on
  success, finds-or-creates the `Doctor` and returns the JWT in one round-trip.
- **App sends the full number.** Flutter builds `<cc><number>` (via
  `AppConfig.defaultCountryCode`) and the backend uses it as-is.
- **No rate limiting** this pass (MSG91 enforces its own throttle). YAGNI.
- **`/auth/login` is removed** — the Flutter app is the only client.

## Backend design (`acute-api`)

### Endpoints — `/api/v1/otp`

Mobile validated against `^[1-9]\d{10,14}$` (Pydantic field validator).

| Endpoint | Request | Success (200) |
|---|---|---|
| `POST /otp/send` | `{mobile}` | `{sent: true}` |
| `POST /otp/verify` | `{mobile, otp}` | `{token, is_new, onboarding_needed, profile_completion, token_type}` |
| `POST /otp/resend` | `{mobile, voice: bool}` (default `false`) | `{sent: true}` |

`/otp/verify` absorbs the current `/auth/login` body: on MSG91 `type:"success"`
it looks up `Doctor` by `mobile`, creates one if absent, computes completion via
`compute_completion`, and returns `create_access_token(...)` as `LoginResponse`.

### Service — `app/services/msg91.py`

Rewrite `MSG91Service` (drop `verify_otp_token`) with three async methods:

- `send_otp(mobile)` → `POST MSG91_OTP_SEND_URL` with query `template_id`,
  `mobile`, `authkey`; no JSON body (template auto-generates the OTP).
- `verify_otp(mobile, otp)` → `GET MSG91_OTP_VERIFY_URL?otp&mobile`, header `authkey`.
- `resend_otp(mobile, retrytype)` → `GET MSG91_OTP_RETRY_URL?authkey&retrytype&mobile`.

Each inspects the 200 body's `type`:

- `httpx.TransportError` / `HTTPStatusError` → `MSG91UnavailableError` → **502**.
- `type:"error"` on **verify** → `OTPVerificationError(message)` → **401**.
- `type:"error"` on **send/resend** → `MSG91RequestError(message)` → **502**.

Keep authkey/token/otp out of logs (log `type` + `message` only).

### Schemas — `app/schemas/otp.py`

- `OTPSendRequest {mobile}` / `OTPSendResponse {sent: bool}`
- `OTPVerifyRequest {mobile, otp}` → returns existing `LoginResponse`
- `OTPResendRequest {mobile, voice: bool = False}` / reuse `OTPSendResponse`

### Config — `app/core/config.py` + `.env.example`

Add:
```
MSG91_OTP_TEMPLATE_ID: str = ""
MSG91_OTP_SEND_URL:   str = "https://control.msg91.com/api/v5/otp"
MSG91_OTP_VERIFY_URL: str = "https://control.msg91.com/api/v5/otp/verify"
MSG91_OTP_RETRY_URL:  str = "https://control.msg91.com/api/v5/otp/retry"
```
Remove `MSG91_VERIFY_URL`. `.env` already holds `MSG91_AUTHKEY` +
`MSG91_OTP_TEMPLATE_ID`; mirror the template key into `.env.example`.

### Removals

- `app/api/v1/endpoints/auth.py` (`/login`) and its router include in `router.py`.
- `verify_otp_token` and the widget verify URL.

## Flutter design (`acute-doctor`)

### Remove

- `lib/features/auth/data/msg91_otp_service.dart`.
- `sendotp_flutter_sdk: ^0.0.2` from `pubspec.yaml`.
- `OTPWidget.initializeWidget(...)` block in `bootstrap.dart`, the
  `msg91WidgetId`/`msg91TokenAuth` params, and the `_msg91WidgetId` /
  `_msg91TokenAuth` `String.fromEnvironment` consts in `main_dev/staging/prod.dart`.

### Add — `OtpApi` (Retrofit)

New `lib/features/auth/data/otp_api.dart` on the existing Dio:
```dart
@POST('/api/v1/otp/send')   Future<void> sendOtp(@Body() Map body);     // {mobile}
@POST('/api/v1/otp/verify') Future<LoginResponse> verifyOtp(@Body() Map body); // {mobile, otp}
@POST('/api/v1/otp/resend') Future<void> resendOtp(@Body() Map body);   // {mobile, voice}
```
`verifyOtp` reuses the existing `LoginResponse` (`onboarding/data/models/login_models.dart`).

### `OtpRepository` contract

```dart
Future<Either<Failure, Unit>>          sendOtp({required String mobile});
Future<Either<Failure, LoginResponse>> verifyOtp({required String mobile, required String otp});
Future<Either<Failure, Unit>>          resendOtp({required String mobile, bool voice});
```
`reqId` is gone. `OtpRepositoryImpl` still prepends `AppConfig.defaultCountryCode`
to build the full number, calls `OtpApi`, and maps via the existing `_guard`.

### `AuthController` (`auth_providers.dart`)

- Remove `msg91OtpServiceProvider`; `otpRepositoryProvider` now wires `OtpApi`.
- Drop `reqId` from `AuthState`.
- `sendOtp(mobile)` stores `mobile` (no reqId).
- `verifyOtp(otp)` calls `repo.verifyOtp(mobile, otp)`, writes the returned
  token to secure storage, sets `authTokenProvider`, `verifiedMobile`,
  `onboardingNeeded`. Deletes `_exchange` and the `_doctorRepo.login` dependency.
- `resendOtp({voice})` calls `repo.resendOtp(mobile, voice)`.
- `otp_page.dart` / `login_page.dart` unchanged (never referenced `reqId`).

Run `dart run build_runner build --delete-conflicting-outputs` for freezed/retrofit.

## Testing

- **Backend (TDD per craft-api):** `respx`-mock MSG91 in `tests/api/v1/test_otp.py`:
  - send: success / `type:error` → 502 / transport → 502
  - verify: new doctor (200 + token, `is_new=true`), existing doctor
    (`is_new=false`), wrong/expired OTP → 401, upstream down → 502
  - resend: success (text + voice) / error
  - Delete `tests/api/v1/test_auth_login.py` (endpoint removed).
- **Flutter:** no existing tests reference the SDK; add an `OtpRepositoryImpl`
  mapping test if cheap.

## Docs

- Add `acute-api/doc/v1/otp.md` (send/verify/resend); remove the auth-login doc.
- Update CLAUDE.md's MSG91 note (service now owns the full OTP lifecycle).

## Out of scope

Rate limiting, WhatsApp/email channels, OTP attempt lockout.
