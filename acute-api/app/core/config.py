from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str = "Shield API"
    API_V1_STR: str = "/api/v1"
    VERSION: str = "0.1.0"

    MSG91_AUTHKEY: str = ""
    MSG91_VERIFY_URL: str = "https://control.msg91.com/api/v5/widget/verifyAccessToken"

    JWT_SECRET: str = "change-me-in-env"
    JWT_ALG: str = "HS256"
    JWT_EXP_DAYS: int = 30

    DATABASE_URL: str = (
        "postgresql+asyncpg://acute-user@localhost:5432/acute-db"
    )
    REDIS_URL: str = "redis://localhost:6379/0"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")


settings = Settings()
