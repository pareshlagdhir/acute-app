# Auth API

**Version:** v1  
**Base path:** `/api/v1`

---

## Overview

Exchanges a verified MSG91 OTP `access_token` for a Shield session JWT.  
Call `POST /otp/verify` first to confirm the user's phone number; once that returns `verified: true`, pass the same `access_token` here to obtain a long-lived session token.

---

## Endpoints

### POST /auth/login

Verifies the MSG91 OTP `access_token`, upserts the doctor record, and returns a signed JWT together with onboarding state.

#### Request

```
POST /api/v1/auth/login
Content-Type: application/json
```

```json
{
  "access_token": "<jwt_token_from_otp_widget>"
}
```

| Field          | Type   | Required | Description                          |
|----------------|--------|----------|--------------------------------------|
| `access_token` | string | yes      | JWT returned by the MSG91 OTP widget |

#### Response

**200 OK** — login successful

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "is_new": true,
  "onboarding_needed": true,
  "profile_completion": 0
}
```

| Field                | Type    | Description                                                                      |
|----------------------|---------|----------------------------------------------------------------------------------|
| `token`              | string  | Signed JWT — pass as `Authorization: Bearer <token>` on all subsequent requests  |
| `token_type`         | string  | Always `"bearer"`                                                                |
| `is_new`             | boolean | `true` if this is the first login for this mobile number                         |
| `onboarding_needed`  | boolean | `true` when `profile_completion < 100`                                           |
| `profile_completion` | integer | Profile completeness as a percentage (0–100, increments of 20)                   |

---

## Error Responses

| Status | When it occurs                                            |
|--------|-----------------------------------------------------------|
| `401`  | MSG91 returns `verified: false` or no mobile in response |
| `422`  | `access_token` field missing from request body            |
| `502`  | MSG91 API unreachable or returned an HTTP 5xx error       |

---

## Examples

### curl

```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"access_token": "<jwt_token_from_otp_widget>"}'
```

### Python (httpx)

```python
import httpx

response = httpx.post(
    "http://localhost:8000/api/v1/auth/login",
    json={"access_token": "<jwt_token_from_otp_widget>"},
)
data = response.json()
token = data["token"]
headers = {"Authorization": f"Bearer {token}"}
```

---

## Configuration

Set `JWT_SECRET` and `JWT_EXP_DAYS` in your `.env` file (copy from `.env.example`):

```env
JWT_SECRET=change-me-to-a-long-random-string
JWT_EXP_DAYS=30
```

---

## Notes

- The `access_token` is produced client-side by the MSG91 OTP widget after successful OTP entry. This endpoint re-verifies it server-side via MSG91 before issuing a session token.
- A `401` response means OTP verification failed — the OTP flow must be restarted client-side.
- `onboarding_needed: true` means the doctor has not yet completed all five profile sections. Direct new users to the onboarding flow; see [doctors.md](doctors.md) for the completion model.
