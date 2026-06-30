# OTP API (`/api/v1/otp`)

Server-side OTP via MSG91 v5 REST API. `mobile` is `<countrycode><10-digit>`
(digits only, no `+`, no leading `0`), e.g. `919876543210`.

## POST /api/v1/otp/send
Request: `{ "mobile": "919876543210" }`
Response 200: `{ "sent": true }`
Errors: 422 invalid mobile · 502 MSG91 unavailable or rejected (e.g. bad template).

## POST /api/v1/otp/verify
Verifies the OTP and, on success, finds-or-creates the doctor and returns a JWT session.
Request: `{ "mobile": "919876543210", "otp": "123456" }`
Response 200: `{ "token": "...", "token_type": "bearer", "is_new": true, "onboarding_needed": true, "profile_completion": 0 }`
Errors: 401 wrong/expired OTP · 422 missing field · 502 MSG91 unavailable.

## POST /api/v1/otp/resend
Request: `{ "mobile": "919876543210", "voice": false }`  (`voice: true` → voice channel, else SMS/text)
Response 200: `{ "sent": true }`
Errors: 422 invalid mobile · 502 MSG91 unavailable or rejected.
