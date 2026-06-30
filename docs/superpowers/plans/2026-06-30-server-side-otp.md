# Server-side OTP via MSG91 v5 REST API — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the OTP send/verify/resend lifecycle from the Flutter `sendotp_flutter_sdk` widget into the FastAPI backend using MSG91's v5 OTP REST API, with verify also issuing the app's JWT session.

**Architecture:** Backend gains three `/api/v1/otp` endpoints backed by a rewritten `MSG91Service` that calls MSG91's v5 OTP API server-side (authkey + template never leave the server). `/otp/verify` absorbs the old `/auth/login` logic (find-or-create `Doctor`, issue JWT). The Flutter app drops the MSG91 SDK and calls these endpoints through a new Retrofit `OtpApi`.

**Tech Stack:** FastAPI, httpx, Pydantic v2, pytest + respx (backend); Flutter, Riverpod, Dio + Retrofit, freezed, dartz (mobile).

## Global Constraints

- Mobile format sent to MSG91 and stored on `Doctor.mobile`: `<countrycode><10-digit>`, digits only, no `+`, no leading `0`. Backend validation regex: `^[1-9]\d{10,14}$`.
- All MSG91 v5 responses are **HTTP 200** with body `{"type": "success"|"error", ...}`; success/failure is determined by `type`, not status code.
- Error mapping: transport failure → **502**; MSG91 `type:"error"` on send/resend → **502**; MSG91 `type:"error"` on verify → **401**.
- Never log authkey, OTP, or JWT — log only MSG91 `type` and `message`.
- Backend tests use `respx` to mock MSG91; no live network calls.
- The Flutter app sends the **full** number; `OtpRepositoryImpl` prepends `AppConfig.defaultCountryCode` to the national number it receives from state.
- Frequent commits: one per task minimum.

---

## Backend (`acute-api`)

### Task 1: Rewrite MSG91Service for the v5 OTP API (+ config & exceptions)

**Files:**
- Modify: `acute-api/app/core/config.py`
- Modify: `acute-api/app/core/exceptions.py`
- Modify: `acute-api/app/services/msg91.py`
- Test: `acute-api/tests/services/test_msg91_service.py` (create)

**Interfaces:**
- Consumes: `settings.MSG91_AUTHKEY`, `settings.MSG91_OTP_TEMPLATE_ID`, the three MSG91 URL settings.
- Produces:
  - `MSG91Service(client: httpx.AsyncClient)`
  - `await svc.send_otp(mobile: str) -> None`
  - `await svc.verify_otp(mobile: str, otp: str) -> None`
  - `await svc.resend_otp(mobile: str, retrytype: str) -> None`  (`retrytype` ∈ `{"text","voice"}`)
  - Exceptions: `MSG91UnavailableError`, `MSG91RequestError`, `OTPVerificationError`

- [ ] **Step 1: Add config keys**

In `acute-api/app/core/config.py`, replace the `MSG91_VERIFY_URL` line with:

```python
    MSG91_AUTHKEY: str = ""
    MSG91_OTP_TEMPLATE_ID: str = ""
    MSG91_OTP_SEND_URL: str = "https://control.msg91.com/api/v5/otp"
    MSG91_OTP_VERIFY_URL: str = "https://control.msg91.com/api/v5/otp/verify"
    MSG91_OTP_RETRY_URL: str = "https://control.msg91.com/api/v5/otp/retry"
```

(Keep `MSG91_AUTHKEY` only once — remove the old standalone line if duplicated. Delete `MSG91_VERIFY_URL` entirely.)

- [ ] **Step 2: Add exception types**

Replace the contents of `acute-api/app/core/exceptions.py` with:

```python
class MSG91UnavailableError(Exception):
    """MSG91 was unreachable (transport/connection failure)."""


class MSG91RequestError(Exception):
    """MSG91 returned type=error for send/resend (e.g. invalid template_id)."""


class OTPVerificationError(Exception):
    """MSG91 returned type=error for verify (wrong or expired OTP)."""
```

- [ ] **Step 3: Write the failing service test**

Create `acute-api/tests/services/test_msg91_service.py`:

```python
import httpx
import pytest
import respx

from app.core.config import settings
from app.core.exceptions import (
    MSG91RequestError,
    MSG91UnavailableError,
    OTPVerificationError,
)
from app.services.msg91 import MSG91Service


@pytest.fixture
async def svc():
    async with httpx.AsyncClient() as client:
        yield MSG91Service(client)


async def test_send_otp_success(svc: MSG91Service) -> None:
    with respx.mock:
        respx.post(settings.MSG91_OTP_SEND_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "request_id": "abc"})
        )
        await svc.send_otp("919876543210")  # no exception == pass


async def test_send_otp_error_raises_request_error(svc: MSG91Service) -> None:
    with respx.mock:
        respx.post(settings.MSG91_OTP_SEND_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "invalid template"})
        )
        with pytest.raises(MSG91RequestError):
            await svc.send_otp("919876543210")


async def test_send_otp_transport_error_raises_unavailable(svc: MSG91Service) -> None:
    with respx.mock:
        respx.post(settings.MSG91_OTP_SEND_URL).mock(side_effect=httpx.ConnectError("down"))
        with pytest.raises(MSG91UnavailableError):
            await svc.send_otp("919876543210")


async def test_verify_otp_success(svc: MSG91Service) -> None:
    with respx.mock:
        respx.get(settings.MSG91_OTP_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "OTP verified success"})
        )
        await svc.verify_otp("919876543210", "1234")


async def test_verify_otp_error_raises_verification_error(svc: MSG91Service) -> None:
    with respx.mock:
        respx.get(settings.MSG91_OTP_VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "OTP expired"})
        )
        with pytest.raises(OTPVerificationError):
            await svc.verify_otp("919876543210", "0000")


async def test_resend_otp_success(svc: MSG91Service) -> None:
    with respx.mock:
        respx.get(settings.MSG91_OTP_RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "retry send successfully"})
        )
        await svc.resend_otp("919876543210", "text")


async def test_resend_otp_error_raises_request_error(svc: MSG91Service) -> None:
    with respx.mock:
        respx.get(settings.MSG91_OTP_RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "Mobile number empty"})
        )
        with pytest.raises(MSG91RequestError):
            await svc.resend_otp("919876543210", "voice")
```

- [ ] **Step 4: Run the test to verify it fails**

Run: `cd acute-api && pytest tests/services/test_msg91_service.py -v`
Expected: FAIL — `send_otp`/`verify_otp`/`resend_otp` do not exist (or import error on the new exceptions).

- [ ] **Step 5: Rewrite the service**

Replace the contents of `acute-api/app/services/msg91.py` with:

```python
import logging

import httpx

from app.core.config import settings
from app.core.exceptions import (
    MSG91RequestError,
    MSG91UnavailableError,
    OTPVerificationError,
)

logger = logging.getLogger("app.msg91")


class MSG91Service:
    def __init__(self, client: httpx.AsyncClient) -> None:
        self._client = client

    async def send_otp(self, mobile: str) -> None:
        params = {
            "template_id": settings.MSG91_OTP_TEMPLATE_ID,
            "mobile": mobile,
            "authkey": settings.MSG91_AUTHKEY,
        }
        data = await self._request("POST", settings.MSG91_OTP_SEND_URL, params=params)
        if data.get("type") != "success":
            logger.warning("MSG91 send failed: %s", data.get("message"))
            raise MSG91RequestError(data.get("message") or "OTP send failed")

    async def verify_otp(self, mobile: str, otp: str) -> None:
        params = {"otp": otp, "mobile": mobile}
        headers = {"authkey": settings.MSG91_AUTHKEY}
        data = await self._request(
            "GET", settings.MSG91_OTP_VERIFY_URL, params=params, headers=headers
        )
        if data.get("type") != "success":
            logger.warning("MSG91 verify failed: %s", data.get("message"))
            raise OTPVerificationError(data.get("message") or "OTP verification failed")

    async def resend_otp(self, mobile: str, retrytype: str) -> None:
        params = {
            "authkey": settings.MSG91_AUTHKEY,
            "retrytype": retrytype,
            "mobile": mobile,
        }
        data = await self._request("GET", settings.MSG91_OTP_RETRY_URL, params=params)
        if data.get("type") != "success":
            logger.warning("MSG91 resend failed: %s", data.get("message"))
            raise MSG91RequestError(data.get("message") or "OTP resend failed")

    async def _request(
        self,
        method: str,
        url: str,
        *,
        params: dict[str, str],
        headers: dict[str, str] | None = None,
    ) -> dict:
        try:
            resp = await self._client.request(method, url, params=params, headers=headers)
            resp.raise_for_status()
            return resp.json()
        except httpx.HTTPStatusError as exc:
            raise MSG91UnavailableError(str(exc)) from exc
        except httpx.TransportError as exc:
            raise MSG91UnavailableError(str(exc)) from exc
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `cd acute-api && pytest tests/services/test_msg91_service.py -v`
Expected: PASS (7 passed).

- [ ] **Step 7: Commit**

```bash
git add acute-api/app/core/config.py acute-api/app/core/exceptions.py acute-api/app/services/msg91.py acute-api/tests/services/test_msg91_service.py
git commit -m "feat(api): rewrite MSG91Service for v5 OTP send/verify/resend"
```

---

### Task 2: OTP request/response schemas with mobile validation

**Files:**
- Modify: `acute-api/app/schemas/otp.py` (replace contents)
- Test: `acute-api/tests/schemas/test_otp_schema.py` (create)

**Interfaces:**
- Consumes: `LoginResponse` from `app.schemas.auth` (verify response).
- Produces: `OTPSendRequest{mobile}`, `OTPVerifyRequest{mobile, otp}`, `OTPResendRequest{mobile, voice: bool}`, `OTPSendResponse{sent: bool}`, and a reusable `Mobile` annotated type.

- [ ] **Step 1: Write the failing schema test**

Create `acute-api/tests/schemas/test_otp_schema.py`:

```python
import pytest
from pydantic import ValidationError

from app.schemas.otp import OTPResendRequest, OTPSendRequest, OTPVerifyRequest


def test_valid_mobile_accepted() -> None:
    assert OTPSendRequest(mobile="919876543210").mobile == "919876543210"


@pytest.mark.parametrize("bad", ["0919876543", "+919876543210", "98765", "91abc4567890"])
def test_invalid_mobile_rejected(bad: str) -> None:
    with pytest.raises(ValidationError):
        OTPSendRequest(mobile=bad)


def test_verify_requires_otp() -> None:
    with pytest.raises(ValidationError):
        OTPVerifyRequest(mobile="919876543210")


def test_resend_voice_defaults_false() -> None:
    assert OTPResendRequest(mobile="919876543210").voice is False
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `cd acute-api && pytest tests/schemas/test_otp_schema.py -v`
Expected: FAIL — `OTPSendRequest`/`OTPVerifyRequest`/`OTPResendRequest` not defined.

- [ ] **Step 3: Write the schemas**

Replace the contents of `acute-api/app/schemas/otp.py` with:

```python
import re
from typing import Annotated

from pydantic import AfterValidator, BaseModel

_MOBILE_RE = re.compile(r"^[1-9]\d{10,14}$")


def _validate_mobile(value: str) -> str:
    if not _MOBILE_RE.match(value):
        raise ValueError(
            "mobile must be <countrycode><number>: digits only, no '+', no leading 0"
        )
    return value


Mobile = Annotated[str, AfterValidator(_validate_mobile)]


class OTPSendRequest(BaseModel):
    mobile: Mobile


class OTPVerifyRequest(BaseModel):
    mobile: Mobile
    otp: str


class OTPResendRequest(BaseModel):
    mobile: Mobile
    voice: bool = False


class OTPSendResponse(BaseModel):
    sent: bool = True
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd acute-api && pytest tests/schemas/test_otp_schema.py -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add acute-api/app/schemas/otp.py acute-api/tests/schemas/test_otp_schema.py
git commit -m "feat(api): add OTP request/response schemas with mobile validation"
```

---

### Task 3: OTP endpoints (send / verify+login / resend); remove /auth/login

**Files:**
- Modify: `acute-api/app/api/v1/endpoints/otp.py` (replace contents)
- Modify: `acute-api/app/api/v1/router.py` (remove auth router include)
- Delete: `acute-api/app/api/v1/endpoints/auth.py`
- Delete: `acute-api/app/schemas/auth.py`'s `LoginRequest` is no longer needed but `LoginResponse` stays — **keep the file**, do not delete.
- Modify: `acute-api/tests/api/v1/test_otp.py` (replace contents)
- Delete: `acute-api/tests/api/v1/test_auth_login.py`

**Interfaces:**
- Consumes: `MSG91Service`, the three OTP exceptions (Task 1); OTP schemas (Task 2); `LoginResponse` (`app.schemas.auth`); `compute_completion` (`app.services.profile`); `create_access_token` (`app.core.security`); `Doctor` model; `get_db`.
- Produces: routes `POST /api/v1/otp/send`, `POST /api/v1/otp/verify`, `POST /api/v1/otp/resend`.

- [ ] **Step 1: Replace the endpoint test file**

Replace the contents of `acute-api/tests/api/v1/test_otp.py` with:

```python
import httpx
import respx
from httpx import AsyncClient

from app.core.config import settings

SEND_URL = settings.MSG91_OTP_SEND_URL
VERIFY_URL = settings.MSG91_OTP_VERIFY_URL
RETRY_URL = settings.MSG91_OTP_RETRY_URL

MOBILE = "919876543210"


# --- send ---
async def test_send_success(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(SEND_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "request_id": "r1"})
        )
        resp = await client.post("/api/v1/otp/send", json={"mobile": MOBILE})
    assert resp.status_code == 200
    assert resp.json()["sent"] is True


async def test_send_msg91_error_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(SEND_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "invalid template"})
        )
        resp = await client.post("/api/v1/otp/send", json={"mobile": MOBILE})
    assert resp.status_code == 502


async def test_send_msg91_down_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.post(SEND_URL).mock(side_effect=httpx.ConnectError("down"))
        resp = await client.post("/api/v1/otp/send", json={"mobile": MOBILE})
    assert resp.status_code == 502


async def test_send_rejects_bad_mobile(client: AsyncClient) -> None:
    resp = await client.post("/api/v1/otp/send", json={"mobile": "0123"})
    assert resp.status_code == 422


# --- verify (merged login) ---
async def test_verify_new_doctor_creates_record_and_token(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "OTP verified success"})
        )
        resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE, "otp": "1234"})
    assert resp.status_code == 200
    body = resp.json()
    assert body["is_new"] is True
    assert body["onboarding_needed"] is True
    assert body["profile_completion"] == 0
    assert body["token"]


async def test_verify_existing_doctor_is_not_new(client: AsyncClient, make_doctor) -> None:
    await make_doctor(mobile=MOBILE)
    with respx.mock:
        respx.get(VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success"})
        )
        resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE, "otp": "1234"})
    assert resp.status_code == 200
    assert resp.json()["is_new"] is False


async def test_verify_wrong_otp_returns_401(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(VERIFY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "OTP expired"})
        )
        resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE, "otp": "0000"})
    assert resp.status_code == 401


async def test_verify_msg91_down_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(VERIFY_URL).mock(side_effect=httpx.ConnectError("down"))
        resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE, "otp": "1234"})
    assert resp.status_code == 502


async def test_verify_rejects_missing_otp(client: AsyncClient) -> None:
    resp = await client.post("/api/v1/otp/verify", json={"mobile": MOBILE})
    assert resp.status_code == 422


# --- resend ---
async def test_resend_text_success(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success", "message": "retry send successfully"})
        )
        resp = await client.post("/api/v1/otp/resend", json={"mobile": MOBILE})
    assert resp.status_code == 200
    assert resp.json()["sent"] is True


async def test_resend_voice_success(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "success"})
        )
        resp = await client.post("/api/v1/otp/resend", json={"mobile": MOBILE, "voice": True})
    assert resp.status_code == 200


async def test_resend_error_returns_502(client: AsyncClient) -> None:
    with respx.mock:
        respx.get(RETRY_URL).mock(
            return_value=httpx.Response(200, json={"type": "error", "message": "Mobile number empty"})
        )
        resp = await client.post("/api/v1/otp/resend", json={"mobile": MOBILE})
    assert resp.status_code == 502
```

- [ ] **Step 2: Delete the obsolete auth-login test**

```bash
git rm acute-api/tests/api/v1/test_auth_login.py
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `cd acute-api && pytest tests/api/v1/test_otp.py -v`
Expected: FAIL — endpoints still expect `access_token` / return `verified`.

- [ ] **Step 4: Rewrite the endpoint module**

Replace the contents of `acute-api/app/api/v1/endpoints/otp.py` with:

```python
import httpx
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import (
    MSG91RequestError,
    MSG91UnavailableError,
    OTPVerificationError,
)
from app.core.security import create_access_token
from app.db.session import get_db
from app.models.doctor import Doctor
from app.schemas.auth import LoginResponse
from app.schemas.otp import (
    OTPResendRequest,
    OTPSendRequest,
    OTPSendResponse,
    OTPVerifyRequest,
)
from app.services.msg91 import MSG91Service
from app.services.profile import compute_completion

router = APIRouter()


@router.post("/send", response_model=OTPSendResponse, summary="Send an OTP via MSG91")
async def send_otp(body: OTPSendRequest) -> OTPSendResponse:
    async with httpx.AsyncClient() as http:
        svc = MSG91Service(http)
        try:
            await svc.send_otp(body.mobile)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail="MSG91 service unavailable") from exc
        except MSG91RequestError as exc:
            raise HTTPException(status_code=502, detail=str(exc)) from exc
    return OTPSendResponse(sent=True)


@router.post("/verify", response_model=LoginResponse, summary="Verify OTP and issue a session")
async def verify_otp(
    body: OTPVerifyRequest, db: AsyncSession = Depends(get_db)
) -> LoginResponse:
    async with httpx.AsyncClient() as http:
        svc = MSG91Service(http)
        try:
            await svc.verify_otp(body.mobile, body.otp)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail="MSG91 service unavailable") from exc
        except OTPVerificationError as exc:
            raise HTTPException(status_code=401, detail=str(exc)) from exc

    existing = (
        await db.execute(select(Doctor).where(Doctor.mobile == body.mobile))
    ).scalar_one_or_none()
    is_new = existing is None
    doctor = existing or Doctor(mobile=body.mobile)
    if is_new:
        db.add(doctor)
        await db.commit()
        await db.refresh(doctor)

    pct, _ = compute_completion(doctor)
    return LoginResponse(
        token=create_access_token(str(doctor.id)),
        is_new=is_new,
        onboarding_needed=pct < 100,
        profile_completion=pct,
    )


@router.post("/resend", response_model=OTPSendResponse, summary="Resend an OTP via MSG91")
async def resend_otp(body: OTPResendRequest) -> OTPSendResponse:
    retrytype = "voice" if body.voice else "text"
    async with httpx.AsyncClient() as http:
        svc = MSG91Service(http)
        try:
            await svc.resend_otp(body.mobile, retrytype)
        except MSG91UnavailableError as exc:
            raise HTTPException(status_code=502, detail="MSG91 service unavailable") from exc
        except MSG91RequestError as exc:
            raise HTTPException(status_code=502, detail=str(exc)) from exc
    return OTPSendResponse(sent=True)
```

- [ ] **Step 5: Remove the auth router**

In `acute-api/app/api/v1/router.py`:
- Remove the import line `from app.api.v1.endpoints.auth import router as auth_router`.
- Remove the line `api_v1_router.include_router(auth_router, prefix="/auth", tags=["auth"])`.

Then delete the endpoint module:

```bash
git rm acute-api/app/api/v1/endpoints/auth.py
```

- [ ] **Step 6: Run the OTP tests to verify they pass**

Run: `cd acute-api && pytest tests/api/v1/test_otp.py -v`
Expected: PASS (12 passed).

- [ ] **Step 7: Run the full backend suite**

Run: `cd acute-api && pytest -q`
Expected: PASS, no references to the removed `/auth/login` or `verify_otp_token`. If any other test imports `auth.py` or `LoginRequest`, update or remove it.

- [ ] **Step 8: Commit**

```bash
git add acute-api/app/api/v1/endpoints/otp.py acute-api/app/api/v1/router.py acute-api/tests/api/v1/test_otp.py
git commit -m "feat(api): server-side OTP send/verify/resend; verify issues session; drop /auth/login"
```

---

### Task 4: Backend docs, env template, and project notes

**Files:**
- Create: `acute-api/doc/v1/otp.md`
- Modify: `acute-api/.env.example`
- Delete: any `acute-api/doc/v1/auth*.md` (login doc, if present)
- Modify: `CLAUDE.md` (root) — MSG91 note

- [ ] **Step 1: Update the env template**

In `acute-api/.env.example`, under the MSG91 section add:

```
MSG91_AUTHKEY=your_msg91_authkey_here
MSG91_OTP_TEMPLATE_ID=your_msg91_otp_template_id_here
```

- [ ] **Step 2: Remove the obsolete auth-login doc (if any)**

Run: `ls acute-api/doc/v1/` — if a login/auth doc exists, `git rm acute-api/doc/v1/<that-file>.md`.

- [ ] **Step 3: Write the OTP endpoint doc**

Create `acute-api/doc/v1/otp.md`:

```markdown
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
```

- [ ] **Step 4: Update root CLAUDE.md**

In `CLAUDE.md`, update the MSG91 mention so it reads that `MSG91Service` now owns the full server-side OTP lifecycle (send/verify/resend) via the v5 OTP REST API, and that `/api/v1/otp/verify` issues the JWT session (there is no `/auth/login`). Find the existing line referencing "MSG91Service for OTP verification" and the `services/` description and adjust the wording accordingly.

- [ ] **Step 5: Commit**

```bash
git add acute-api/doc/v1/otp.md acute-api/.env.example CLAUDE.md
git commit -m "docs(api): document OTP endpoints; update env template and project notes"
```

---

## Flutter (`acute-doctor`)

### Task 5: OTP request models + Retrofit OtpApi

**Files:**
- Create: `acute-doctor/lib/features/auth/data/models/otp_models.dart`
- Create: `acute-doctor/lib/features/auth/data/otp_api.dart`
- (Generated): `*.freezed.dart`, `*.g.dart` via build_runner

**Interfaces:**
- Consumes: `LoginResponse` (`features/onboarding/data/models/login_models.dart`); `Dio`.
- Produces: `OtpApi(Dio)` with `sendOtp(OtpSendRequest)`, `verifyOtp(OtpVerifyRequest) -> LoginResponse`, `resendOtp(OtpResendRequest)`; request models `OtpSendRequest{mobile}`, `OtpVerifyRequest{mobile, otp}`, `OtpResendRequest{mobile, voice}`.

- [ ] **Step 1: Create the request models**

Create `acute-doctor/lib/features/auth/data/models/otp_models.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_models.freezed.dart';
part 'otp_models.g.dart';

@freezed
abstract class OtpSendRequest with _$OtpSendRequest {
  const factory OtpSendRequest({required String mobile}) = _OtpSendRequest;
  factory OtpSendRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpSendRequestFromJson(json);
}

@freezed
abstract class OtpVerifyRequest with _$OtpVerifyRequest {
  const factory OtpVerifyRequest({
    required String mobile,
    required String otp,
  }) = _OtpVerifyRequest;
  factory OtpVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyRequestFromJson(json);
}

@freezed
abstract class OtpResendRequest with _$OtpResendRequest {
  const factory OtpResendRequest({
    required String mobile,
    @Default(false) bool voice,
  }) = _OtpResendRequest;
  factory OtpResendRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpResendRequestFromJson(json);
}
```

- [ ] **Step 2: Create the Retrofit API**

Create `acute-doctor/lib/features/auth/data/otp_api.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../onboarding/data/models/login_models.dart';
import 'models/otp_models.dart';

part 'otp_api.g.dart';

@RestApi()
abstract class OtpApi {
  factory OtpApi(Dio dio) = _OtpApi;

  @POST('/api/v1/otp/send')
  Future<void> sendOtp(@Body() OtpSendRequest body);

  @POST('/api/v1/otp/verify')
  Future<LoginResponse> verifyOtp(@Body() OtpVerifyRequest body);

  @POST('/api/v1/otp/resend')
  Future<void> resendOtp(@Body() OtpResendRequest body);
}
```

- [ ] **Step 3: Generate code**

Run: `cd acute-doctor && dart run build_runner build --delete-conflicting-outputs`
Expected: generates `otp_models.freezed.dart`, `otp_models.g.dart`, `otp_api.g.dart` with no errors.

- [ ] **Step 4: Analyze**

Run: `cd acute-doctor && flutter analyze lib/features/auth/data/otp_api.dart lib/features/auth/data/models/otp_models.dart`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add acute-doctor/lib/features/auth/data/models/otp_models.dart acute-doctor/lib/features/auth/data/models/otp_models.freezed.dart acute-doctor/lib/features/auth/data/models/otp_models.g.dart acute-doctor/lib/features/auth/data/otp_api.dart acute-doctor/lib/features/auth/data/otp_api.g.dart
git commit -m "feat(app): add OTP request models and Retrofit OtpApi"
```

---

### Task 6: OtpRepository contract + impl over OtpApi

**Files:**
- Modify: `acute-doctor/lib/features/auth/domain/otp_repository.dart` (replace contents)
- Modify: `acute-doctor/lib/features/auth/data/otp_repository_impl.dart` (replace contents)
- Test: `acute-doctor/test/features/auth/otp_repository_impl_test.dart` (create)

**Interfaces:**
- Consumes: `OtpApi` (Task 5), `LoginResponse`, `AppConfig`, the dartz `_guard` error mapping pattern.
- Produces: `OtpRepository` with `sendOtp({mobile}) -> Either<Failure, Unit>`, `verifyOtp({mobile, otp}) -> Either<Failure, LoginResponse>`, `resendOtp({mobile, voice}) -> Either<Failure, Unit>`. The `mobile` argument is the **national** number; the impl prepends the country code.

- [ ] **Step 1: Write the failing repository test**

Create `acute-doctor/test/features/auth/otp_repository_impl_test.dart`:

```dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:acute_doctor/core/config/app_config.dart';
import 'package:acute_doctor/core/errors/exceptions.dart';
import 'package:acute_doctor/core/errors/failures.dart';
import 'package:acute_doctor/features/auth/data/models/otp_models.dart';
import 'package:acute_doctor/features/auth/data/otp_api.dart';
import 'package:acute_doctor/features/auth/data/otp_repository_impl.dart';
import 'package:acute_doctor/features/onboarding/data/models/login_models.dart';

class _FakeOtpApi implements OtpApi {
  OtpVerifyRequest? lastVerify;
  OtpSendRequest? lastSend;
  Object? error;

  @override
  Future<void> sendOtp(OtpSendRequest body) async {
    lastSend = body;
    if (error != null) throw error!;
  }

  @override
  Future<LoginResponse> verifyOtp(OtpVerifyRequest body) async {
    lastVerify = body;
    if (error != null) throw error!;
    return const LoginResponse(
      token: 't', isNew: true, onboardingNeeded: true, profileCompletion: 0,
    );
  }

  @override
  Future<void> resendOtp(OtpResendRequest body) async {
    if (error != null) throw error!;
  }
}

void main() {
  late _FakeOtpApi api;
  late OtpRepositoryImpl repo;

  setUp(() {
    AppConfig.init(defaultCountryCode: '91');
    api = _FakeOtpApi();
    repo = OtpRepositoryImpl(api: api, config: AppConfig.I);
  });

  test('sendOtp prepends country code and returns Unit', () async {
    final res = await repo.sendOtp(mobile: '9876543210');
    expect(res, isA<Right>());
    expect(api.lastSend!.mobile, '919876543210');
  });

  test('verifyOtp returns LoginResponse on success', () async {
    final res = await repo.verifyOtp(mobile: '9876543210', otp: '1234');
    expect(res.isRight(), true);
    expect(api.lastVerify!.mobile, '919876543210');
  });

  test('maps ServerException to ServerFailure', () async {
    api.error = const ServerException('bad otp', code: 'error');
    final res = await repo.verifyOtp(mobile: '9876543210', otp: '0000');
    expect(res.isLeft(), true);
    res.fold((f) => expect(f, isA<ServerFailure>()), (_) => fail('expected Left'));
  });
}
```

> Note: confirm `AppConfig.init(defaultCountryCode: ...)` matches the actual `AppConfig` factory (it has a `defaultCountryCode` param defaulting to `'91'`). If the initializer name differs, adjust the `setUp` to however `AppConfig.I` is seeded in other tests.

- [ ] **Step 2: Run the test to verify it fails**

Run: `cd acute-doctor && flutter test test/features/auth/otp_repository_impl_test.dart`
Expected: FAIL — `OtpRepositoryImpl` still takes a `Msg91OtpService`.

- [ ] **Step 3: Replace the repository contract**

Replace the contents of `acute-doctor/lib/features/auth/domain/otp_repository.dart` with:

```dart
import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../onboarding/data/models/login_models.dart';

/// Contract for the backend OTP flow. The backend (MSG91Service) owns
/// send/verify/resend; the app talks only to our API. `mobile` is the
/// 10-digit national number — the implementation prepends the country code.
abstract interface class OtpRepository {
  /// Sends an OTP to the given national mobile number.
  Future<Either<Failure, Unit>> sendOtp({required String mobile});

  /// Verifies the OTP. On success the backend issues the session, returned
  /// here as a [LoginResponse] (token + onboarding flags).
  Future<Either<Failure, LoginResponse>> verifyOtp({
    required String mobile,
    required String otp,
  });

  /// Re-sends the OTP. [voice] = true requests the voice channel instead of SMS.
  Future<Either<Failure, Unit>> resendOtp({
    required String mobile,
    bool voice,
  });
}
```

- [ ] **Step 4: Replace the repository implementation**

Replace the contents of `acute-doctor/lib/features/auth/data/otp_repository_impl.dart` with:

```dart
import 'package:dartz/dartz.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../onboarding/data/models/login_models.dart';
import '../domain/otp_repository.dart';
import 'models/otp_models.dart';
import 'otp_api.dart';

class OtpRepositoryImpl implements OtpRepository {
  OtpRepositoryImpl({required OtpApi api, required AppConfig config})
      : _api = api,
        _config = config;

  final OtpApi _api;
  final AppConfig _config;

  @override
  Future<Either<Failure, Unit>> sendOtp({required String mobile}) =>
      _guard(() async {
        await _api.sendOtp(OtpSendRequest(mobile: _fullMobile(mobile)));
        return unit;
      });

  @override
  Future<Either<Failure, LoginResponse>> verifyOtp({
    required String mobile,
    required String otp,
  }) =>
      _guard(() => _api.verifyOtp(
            OtpVerifyRequest(mobile: _fullMobile(mobile), otp: otp),
          ));

  @override
  Future<Either<Failure, Unit>> resendOtp({
    required String mobile,
    bool voice = false,
  }) =>
      _guard(() async {
        await _api.resendOtp(
          OtpResendRequest(mobile: _fullMobile(mobile), voice: voice),
        );
        return unit;
      });

  String _fullMobile(String national) => '${_config.defaultCountryCode}$national';

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on AppException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } on Object catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `cd acute-doctor && flutter test test/features/auth/otp_repository_impl_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add acute-doctor/lib/features/auth/domain/otp_repository.dart acute-doctor/lib/features/auth/data/otp_repository_impl.dart acute-doctor/test/features/auth/otp_repository_impl_test.dart
git commit -m "feat(app): OtpRepository over backend OtpApi; verify returns LoginResponse"
```

---

### Task 7: AuthController — drop reqId, fold session into verify

**Files:**
- Modify: `acute-doctor/lib/features/auth/presentation/providers/auth_providers.dart`

**Interfaces:**
- Consumes: `OtpRepository` (Task 6), `OtpApi` (Task 5), `dioProvider`, `authTokenProvider`, `secureStorageProvider` (`core/network/dio_provider.dart`), `AppConfig`, `LoginResponse`.
- Produces: `otpApiProvider`, updated `otpRepositoryProvider`, `AuthController` without `reqId` or any `DoctorRepository` dependency.

- [ ] **Step 1: Replace providers and remove the SDK service provider**

In `auth_providers.dart`, replace the imports + provider block at the top. Remove the `msg91_otp_service.dart`, `doctor_repository.dart`, and `onboarding_providers.dart` imports (the controller no longer logs in via the doctor repo). Keep the `login_models.dart` import (for `LoginResponse`). Add an `otp_api.dart` import.

Replace:

```dart
import '../../data/msg91_otp_service.dart';
import '../../data/otp_repository_impl.dart';
import '../../domain/otp_repository.dart';
import '../../../onboarding/data/models/login_models.dart';
import '../../../onboarding/domain/doctor_repository.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';

final msg91OtpServiceProvider = Provider<Msg91OtpService>(
  (ref) => const Msg91OtpService(),
);

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepositoryImpl(
    service: ref.watch(msg91OtpServiceProvider),
    config: AppConfig.I,
  );
});
```

with:

```dart
import '../../data/otp_api.dart';
import '../../data/otp_repository_impl.dart';
import '../../domain/otp_repository.dart';
import '../../../onboarding/data/models/login_models.dart';

final otpApiProvider = Provider<OtpApi>(
  (ref) => OtpApi(ref.watch(dioProvider)),
);

final otpRepositoryProvider = Provider<OtpRepository>((ref) {
  return OtpRepositoryImpl(
    api: ref.watch(otpApiProvider),
    config: AppConfig.I,
  );
});
```

(Keep the existing `import '../../../../core/network/dio_provider.dart';` — it already exports `dioProvider`, `authTokenProvider`, and `secureStorageProvider`.)

- [ ] **Step 2: Remove `reqId` from AuthState**

In the `AuthState` class: delete the `reqId` field, its doc comment, the constructor parameter `this.reqId`, the `copyWith` parameter `Object? reqId = _sentinel`, and the `reqId:` line in the returned `AuthState`. Leave `mobile`, `verifiedMobile`, `onboardingNeeded`, and the loading flags intact.

- [ ] **Step 3: Drop the DoctorRepository field**

In `AuthController`, remove `late final DoctorRepository _doctorRepo;` and the line `_doctorRepo = ref.watch(doctorRepositoryProvider);` from `build()`.

- [ ] **Step 4: Rewrite sendOtp / verifyOtp / resendOtp and delete `_exchange`**

Replace the `sendOtp`, `verifyOtp`, `_exchange`, and `resendOtp` methods with:

```dart
  Future<bool> sendOtp(String mobile) async {
    state = state.copyWith(isSending: true, error: null);
    final res = await _repo.sendOtp(mobile: mobile);
    return res.fold(
      (f) {
        state = state.copyWith(isSending: false, error: _message(f));
        return false;
      },
      (_) {
        state = state.copyWith(isSending: false, mobile: mobile);
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    final mobile = state.mobile;
    if (mobile == null) {
      state = state.copyWith(error: 'Please request a new code');
      return false;
    }
    state = state.copyWith(isVerifying: true, error: null);
    final res = await _repo.verifyOtp(mobile: mobile, otp: otp);
    final resp = res.fold<LoginResponse?>(
      (f) {
        state = state.copyWith(isVerifying: false, error: _message(f));
        return null;
      },
      (r) => r,
    );
    if (resp == null) return false;
    await _storage.writeAuthToken(resp.token);
    ref.read(authTokenProvider.notifier).token = resp.token;
    state = state.copyWith(
      isVerifying: false,
      verifiedMobile: mobile,
      onboardingNeeded: resp.onboardingNeeded,
    );
    return true;
  }

  Future<bool> resendOtp({bool voice = false}) async {
    final mobile = state.mobile;
    if (mobile == null) {
      state = state.copyWith(error: 'Please request a new code');
      return false;
    }
    state = state.copyWith(isResending: true, error: null);
    final res = await _repo.resendOtp(mobile: mobile, voice: voice);
    return res.fold(
      (f) {
        state = state.copyWith(isResending: false, error: _message(f));
        return false;
      },
      (_) {
        state = state.copyWith(isResending: false);
        return true;
      },
    );
  }
```

- [ ] **Step 5: Analyze**

Run: `cd acute-doctor && flutter analyze lib/features/auth/presentation/providers/auth_providers.dart`
Expected: No issues (no unused imports, no `reqId` references). If `flutter analyze` flags `otp_page.dart` / `login_page.dart`, fix any stray `reqId` reference there — but per the current code neither references it.

- [ ] **Step 6: Commit**

```bash
git add acute-doctor/lib/features/auth/presentation/providers/auth_providers.dart
git commit -m "refactor(app): AuthController calls backend OTP; verify issues session, drop reqId"
```

---

### Task 8: Remove the MSG91 widget SDK and dead wiring

**Files:**
- Delete: `acute-doctor/lib/features/auth/data/msg91_otp_service.dart`
- Modify: `acute-doctor/pubspec.yaml`
- Modify: `acute-doctor/lib/bootstrap.dart`
- Modify: `acute-doctor/lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`

**Interfaces:**
- Consumes: nothing new.
- Produces: a build with no dependency on `sendotp_flutter_sdk`.

- [ ] **Step 1: Delete the SDK wrapper**

```bash
git rm acute-doctor/lib/features/auth/data/msg91_otp_service.dart
```

- [ ] **Step 2: Remove the dependency**

In `acute-doctor/pubspec.yaml`, delete the line:

```
  sendotp_flutter_sdk: ^0.0.2
```

- [ ] **Step 3: Strip the widget init from bootstrap.dart**

In `acute-doctor/lib/bootstrap.dart`:
- Remove `import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';`.
- Remove the `String msg91WidgetId = '',` and `String msg91TokenAuth = '',` parameters from the bootstrap function signature.
- Remove the `msg91WidgetId: msg91WidgetId,` and `msg91TokenAuth: msg91TokenAuth,` arguments wherever they are forwarded.
- Remove the block:

```dart
  if (msg91WidgetId.isNotEmpty && msg91TokenAuth.isNotEmpty) {
    OTPWidget.initializeWidget(msg91WidgetId, msg91TokenAuth);
  }
```

Read the file first to capture the exact surrounding lines (the `AppConfig.init` call that consumes `msg91WidgetId`/`msg91TokenAuth` must drop those two named args too — verify `AppConfig.init` no longer needs them; if `AppConfig` declares `msg91WidgetId`/`msg91TokenAuth` fields, remove those fields and params as well).

- [ ] **Step 4: Strip MSG91 env consts from the entrypoints**

In each of `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`:
- Remove the two consts:

```dart
const _msg91WidgetId = String.fromEnvironment('MSG91_WIDGET_ID');
const _msg91TokenAuth = String.fromEnvironment('MSG91_TOKEN_AUTH');
```

- Remove the two arguments from the bootstrap call:

```dart
      msg91WidgetId: _msg91WidgetId,
      msg91TokenAuth: _msg91TokenAuth,
```

- [ ] **Step 5: Refresh dependencies**

Run: `cd acute-doctor && flutter pub get`
Expected: resolves with no `sendotp_flutter_sdk`.

- [ ] **Step 6: Analyze the whole app**

Run: `cd acute-doctor && flutter analyze`
Expected: No issues. (Confirms no lingering imports of the deleted service or SDK.)

- [ ] **Step 7: Run the test suite**

Run: `cd acute-doctor && flutter test`
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add acute-doctor/pubspec.yaml acute-doctor/pubspec.lock acute-doctor/lib/bootstrap.dart acute-doctor/lib/main_dev.dart acute-doctor/lib/main_staging.dart acute-doctor/lib/main_prod.dart
git commit -m "chore(app): remove sendotp_flutter_sdk and MSG91 widget wiring"
```

---

## Self-Review

**Spec coverage:**
- Endpoints `/otp/send|verify|resend` → Task 3. ✓
- Verify merges login, `/auth/login` removed → Task 3. ✓
- Service rewrite (3 methods, error mapping) → Task 1. ✓
- Config keys + remove `MSG91_VERIFY_URL` → Task 1; `.env.example` → Task 4. ✓
- Mobile validation regex → Task 2. ✓
- App sends full number / repo prepends country code → Task 6. ✓
- Remove `Msg91OtpService` + SDK + bootstrap/main wiring → Task 8. ✓
- `OtpApi` Retrofit, `verifyOtp` returns `LoginResponse` → Task 5. ✓
- AuthController drops `reqId`, folds session → Task 7. ✓
- Tests (backend respx per case; Flutter repo test) → Tasks 1,2,3,6. ✓
- Docs `otp.md`, remove auth doc, CLAUDE.md → Task 4. ✓
- No rate limiting (out of scope) → honored. ✓

**Placeholder scan:** No TBD/TODO; every code step has full code. ✓

**Type consistency:** `send_otp/verify_otp/resend_otp(mobile, [otp|retrytype])` consistent across Tasks 1↔3; `OtpApi.sendOtp/verifyOtp/resendOtp` and `OtpSendRequest/OtpVerifyRequest/OtpResendRequest` consistent across Tasks 5↔6↔7; `verifyOtp` returns `LoginResponse` everywhere; `OtpRepository` method signatures match between contract (Task 6) and controller usage (Task 7). ✓

**Risk flags for the implementer:**
- Task 6 Step 1: the test's `AppConfig.init(...)` / package import name (`package:acute_doctor/...`) must match the real package name in `pubspec.yaml` and the actual `AppConfig` seeding API — adjust if different.
- Task 5/Retrofit: `Future<void>` return types require the generated client to ignore the body; this matches the existing `deleteEducation`/`deleteWorkingHour` `Future<void>` pattern in `DoctorApi`, so it is supported.
- Task 8 Step 3: read `bootstrap.dart` and `AppConfig` fully before editing — remove the `msg91WidgetId`/`msg91TokenAuth` fields/params wherever they thread through, not just the init block.
