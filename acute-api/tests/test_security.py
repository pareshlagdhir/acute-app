import pytest
from jwt import InvalidTokenError

from app.core.security import create_access_token, decode_access_token


def test_roundtrip_returns_subject() -> None:
    token = create_access_token("doctor-123")
    assert decode_access_token(token) == "doctor-123"


def test_decode_rejects_garbage() -> None:
    with pytest.raises(InvalidTokenError):
        decode_access_token("not-a-token")
