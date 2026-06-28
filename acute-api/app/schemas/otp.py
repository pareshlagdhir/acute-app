from pydantic import BaseModel


class OTPVerifyRequest(BaseModel):
    access_token: str


class OTPVerifyResponse(BaseModel):
    verified: bool
    mobile: str | None = None
    message: str | None = None
