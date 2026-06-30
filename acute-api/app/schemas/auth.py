from pydantic import BaseModel


class LoginResponse(BaseModel):
    token: str
    token_type: str = "bearer"
    is_new: bool
    onboarding_needed: bool
    profile_completion: int
