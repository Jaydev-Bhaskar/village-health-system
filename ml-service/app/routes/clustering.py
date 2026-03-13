from fastapi import APIRouter, HTTPException
from app.schemas import ClusterHousesRequest, ClusterHousesResponse
from app.services.balanced_clustering import perform_balanced_clustering
from app.logger import logger

router = APIRouter()

@router.post("/cluster-houses", response_model=ClusterHousesResponse)
async def cluster_houses(request: ClusterHousesRequest):
    logger.info(f"Received request to cluster houses for {request.students} students.")
    try:
        clusters = perform_balanced_clustering(request.students, request.houses)
        return ClusterHousesResponse(clusters=clusters)
    except ValueError as ve:
        logger.warning(f"Validation error in clustering: {ve}")
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        logger.error(f"Clustering algorithm failure: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during clustering.")
