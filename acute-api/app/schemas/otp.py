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


class OTPVerifyResponse(BaseModel):
    verified: bool
    mobile: str | None = None
    message: str | None = None
