import numpy as np
from typing import List
from app.schemas import House
from app.logger import logger

def optimize_route(houses: List[House]) -> List[str]:
    """
    Optimize visiting order of houses using the Nearest Neighbor TSP heuristic.
    Uses Euclidean distance between latitude and longitude coordinates.
    """
    logger.info(f"Optimizing route for {len(houses)} houses.")
    
    if not houses:
        return []
    
    unvisited = houses.copy()
    
    # 1. Start from the first house
    current_house = unvisited.pop(0)
    route_ids = [current_house.id]
    
    # Continue until all houses are visited
    while unvisited:
        # 2. Compute distance to all remaining houses
        # Euclidean distance using numpy
        current_coord = np.array([current_house.lat, current_house.lng])
        unvisited_coords = np.array([[h.lat, h.lng] for h in unvisited])
        
        # Calculate squared Euclidean distances (faster, sufficient for finding minimum)
        distances = np.sum((unvisited_coords - current_coord) ** 2, axis=1)
        
        # 3. Select nearest unvisited house
        nearest_idx = np.argmin(distances)
        
        # Move to nearest house and add to route
        current_house = unvisited.pop(nearest_idx)
        route_ids.append(current_house.id)
        
    logger.info(f"Route optimization complete. Route length: {len(route_ids)}")
    return route_ids
