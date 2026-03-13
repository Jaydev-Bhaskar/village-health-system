import numpy as np
from sklearn.cluster import KMeans
from scipy.spatial.distance import cdist
from typing import List, Dict
from app.schemas import House
from app.logger import logger

def perform_balanced_clustering(students: int, houses: List[House]) -> Dict[str, List[str]]:
    """
    Perform balanced clustering assigning exactly 5 houses to each student.
    Uses KMeans for initialization and greedy assignment based on distance.
    """
    logger.info(f"Starting balanced clustering for {students} students and {len(houses)} houses.")
    
    if len(houses) != students * 5:
        logger.error(f"Mismatch: {len(houses)} houses for {students} students. Expected {students * 5}.")
        raise ValueError(f"Number of houses must be exactly 5 times the number of students. Got {len(houses)} houses and {students} students.")
        
    coords = np.array([[h.lat, h.lng] for h in houses])
    house_ids = [h.id for h in houses]
    
    # 1. Initialize cluster centers using KMeans
    kmeans = KMeans(n_clusters=students, random_state=42, n_init=10)
    kmeans.fit(coords)
    centers = kmeans.cluster_centers_
    
    # 2. Compute distance matrix between houses and cluster centers
    # Shape: (num_houses, num_students)
    distances = cdist(coords, centers)
    
    # 3. Assign houses greedily enforcing cluster capacity of 5
    clusters = {str(i): [] for i in range(students)}
    cluster_counts = {str(i): 0 for i in range(students)}
    
    # Flat list of (house_index, cluster_index, distance)
    assignments = []
    for h_idx in range(len(houses)):
        for c_idx in range(students):
            assignments.append((h_idx, c_idx, distances[h_idx, c_idx]))
            
    # Sort all possible assignments by distance
    assignments.sort(key=lambda x: x[2])
    
    assigned_houses = set()
    
    for h_idx, c_idx, dist in assignments:
        c_str = str(c_idx)
        # If house not assigned and cluster has capacity
        if h_idx not in assigned_houses and cluster_counts[c_str] < 5:
            clusters[c_str].append(house_ids[h_idx])
            assigned_houses.add(h_idx)
            cluster_counts[c_str] += 1
            if len(assigned_houses) == len(houses):
                break
                
    logger.info("Successfully completed balanced clustering.")
    return clusters
