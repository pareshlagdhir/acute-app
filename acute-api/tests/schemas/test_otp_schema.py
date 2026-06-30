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
