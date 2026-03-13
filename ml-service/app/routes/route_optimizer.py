from fastapi import APIRouter, HTTPException
from app.schemas import RouteOptimizationRequest, RouteOptimizationResponse
from app.services.route_optimizer import optimize_route
from app.logger import logger

router = APIRouter()

@router.post("/optimize-route", response_model=RouteOptimizationResponse)
async def optimize_route_endpoint(request: RouteOptimizationRequest):
    logger.info(f"Received request to optimize route for {len(request.houses)} houses.")
    try:
        if not request.houses:
            raise ValueError("The houses list cannot be empty.")
        route = optimize_route(request.houses)
        return RouteOptimizationResponse(route=route)
    except ValueError as ve:
        logger.warning(f"Validation error in Route Optimization: {ve}")
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        logger.error(f"Route Optimization algorithm failure: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during route optimization.")
