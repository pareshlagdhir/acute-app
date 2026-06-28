# OTP API

**Version:** v1
**Base path:** `/api/v1`

---

## Overview

Server-side verification of a JWT token issued by the MSG91 OTP widget.  
The widget runs client-side and produces an `access-token` after the user completes OTP entry.
Your backend calls this endpoint to confirm the token is valid before granting access.

---

## Endpoints

### POST /otp/verify

Verifies a MSG91 OTP widget `access-token` by forwarding it to MSG91's
`verifyAccessToken` endpoint using the configured server-side authkey.

#### Request

```
POST /api/v1/otp/verify
Content-Type: application/json
```

```json
{
  "access_token": "<jwt_token_from_otp_widget>"
}
```

| Field          | Type   | Required | Description                              |
|----------------|--------|----------|------------------------------------------|
| `access_token` | string | yes      | JWT returned by the MSG91 OTP widget     |

#### Response

**200 OK** — token evaluated (check `verified` field for outcome)

```json
{
  "verified": true,
  "mobile": "91XXXXXXXXXX",
  "message": "Mobile verified successfully."
}
```

| Field      | Type          | Description                                   |
|------------|---------------|-----------------------------------------------|
| `verified` | boolean       | `true` if MSG91 confirms the token is valid   |
| `mobile`   | string / null | Phone number if verification succeeded        |
| `message`  | string / null | Human-readable message from MSG91             |

**200 OK** — token invalid or expired

```json
{
  "verified": false,
  "mobile": null,
  "message": "Token expired or invalid."
}
```

---

## Error Responses

| Status | When it occurs                              |
|--------|---------------------------------------------|
| `422`  | `access_token` field missing from body      |
| `502`  | MSG91 API unreachable or returned HTTP 5xx  |

---

## Examples

### curl

```bash
curl -X POST http://localhost:8000/api/v1/otp/verify \
  -H "Content-Type: application/json" \
  -d '{"access_token": "<jwt_token_from_otp_widget>"}'
```

### Python (httpx)

```python
import httpx

response = httpx.post(
    "http://localhost:8000/api/v1/otp/verify",
    json={"access_token": "<jwt_token_from_otp_widget>"},
)
data = response.json()
if data["verified"]:
    print("User verified:", data["mobile"])
```

---

## Configuration

Set `MSG91_AUTHKEY` in your `.env` file (copy from `.env.example`):

```env
MSG91_AUTHKEY=your_msg91_authkey_here
```

---

## Notes

- The `access-token` is produced client-side by the MSG91 OTP widget after the user
  successfully enters the OTP. Never pass your authkey to the client.
- A `verified: false` response with status `200` means the token was evaluated but
  failed — treat it as an authentication failure, not a server error.
- MSG91 upstream errors surface as `502` so your client can distinguish provider
  outages from authentication failures.
