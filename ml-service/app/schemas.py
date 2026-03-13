from pydantic import BaseModel
from typing import List, Dict

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
    bp: str

class RiskDetectionResponse(BaseModel):
    risk: str

class HealthResponse(BaseModel):
    status: str
    service: str

class RouteOptimizationRequest(BaseModel):
    houses: List[House]

class RouteOptimizationResponse(BaseModel):
    route: List[str]
