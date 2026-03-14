from fastapi import APIRouter, HTTPException
from app.schemas import RiskDetectionRequest, RiskDetectionResponse
from app.services.risk_model import determine_risk
from app.logger import logger

router = APIRouter()

@router.post("/risk-detection", response_model=RiskDetectionResponse)
async def risk_detection(request: RiskDetectionRequest):
    logger.info(f"Received risk detection request")
    try:
        risk_data = determine_risk(request)
        return RiskDetectionResponse(**risk_data)
    except ValueError as ve:
        logger.warning(f"Validation error in risk detection: {ve}")
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        logger.error(f"Risk detection failure: {e}")
        raise HTTPException(status_code=500, detail="Internal server error during risk detection.")
