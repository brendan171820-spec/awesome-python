from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "HomeScreen AI API"
    debug: bool = False

    # Database
    database_url: str = "postgresql://user:password@localhost/homescreenai"

    # Redis
    redis_url: str = "redis://localhost:6379"

    # AI Services
    anthropic_api_key: str
    openai_api_key: str  # For DALL-E image generation

    # Auth
    secret_key: str
    access_token_expire_minutes: int = 43200  # 30 days

    # AWS S3 (for storing generated assets)
    aws_access_key_id: str = ""
    aws_secret_access_key: str = ""
    aws_s3_bucket: str = "homescreenai-assets"
    aws_region: str = "eu-west-1"

    # Stripe (in-app purchases)
    stripe_secret_key: str = ""
    stripe_webhook_secret: str = ""

    class Config:
        env_file = ".env"


settings = Settings()
