from pydantic import BaseModel
from typing import List, Dict, Optional

class House(BaseModel):
    id: str
    lat: float
    lng: float

class ClusterHousesRequest(BaseModel):
    students: int
    houses: List[House]

class ClusterHousesResponse(BaseModel):
    clusters: Dict[str, List[str]]

class RiskDetectionRequest(BaseModel):
    bp: Optional[str] = None
    blood_sugar: Optional[float] = None
    weight: Optional[float] = None
    height: Optional[float] = None

class RiskDetectionResponse(BaseModel):
    hypertension: str
    diabetes: str
    obesity: str
    overallRisk: str

class HealthResponse(BaseModel):
    status: str
    service: str

class RouteOptimizationRequest(BaseModel):
    houses: List[House]

class RouteOptimizationResponse(BaseModel):
    route: List[str]
