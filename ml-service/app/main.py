from fastapi import FastAPI
from app.routes import clustering, risk_detection, route_optimizer, health
from app.config import settings
from app.logger import logger

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Machine Learning Microservice for Village Health Monitoring System",
    version="1.0.0",
    docs_url="/docs"
)

# Include routers
app.include_router(health.router, tags=["Health"])
app.include_router(clustering.router, prefix=settings.API_V1_STR, tags=["Clustering"])
app.include_router(risk_detection.router, prefix=settings.API_V1_STR, tags=["Risk Detection"])
app.include_router(route_optimizer.router, prefix=settings.API_V1_STR, tags=["Route Optimization"])

logger.info("FastAPI application initialized and routers included.")
