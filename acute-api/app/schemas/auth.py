from pydantic import BaseModel


class LoginRequest(BaseModel):
    access_token: str


class LoginResponse(BaseModel):
    token: str
    token_type: str = "bearer"
    is_new: bool
    onboarding_needed: bool
    profile_completion: int
