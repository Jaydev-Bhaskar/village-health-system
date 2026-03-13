from fastapi import APIRouter
from app.schemas import HealthResponse
from app.logger import logger

router = APIRouter()

@router.get("/health", response_model=HealthResponse)
async def health_check():
    logger.info("Health check endpoint called.")
    return HealthResponse(status="ok", service="ml-service")
