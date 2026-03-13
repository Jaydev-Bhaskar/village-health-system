# Village Health Monitoring System - ML Service

## Project Overview
This microservice provides machine learning capabilities for the Village Health Monitoring System. It exposes APIs for:
1. **Smart House Allotment**: Uses a balanced clustering algorithm (KMeans + greedy assignment) to assign exactly 5 houses to medical students based on geographic coordinates.
2. **Visit Route Optimization**: Computes the optimal visiting order for a student's assigned houses using a Nearest Neighbor TSP heuristic to minimize travel distance.
3. **Health Risk Detection**: Classifies patient health risk (HIGH, MODERATE, LOW) based on blood pressure readings.

It is built with **FastAPI** to be highly performant, modular, and easy to integrate with the main Node.js backend.

## Architecture Explanation
- **Frontend**: React.js / React Native (Mobile)
- **Backend API**: Node.js + Express (sends HTTP requests to this ML Service)
- **Database**: MongoDB Atlas
- **ML Service (This repo)**: Python + FastAPI
  - Contains modular routing (`app/routes/`)
  - Features validation via Pydantic (`app/schemas.py`)
  - Contains independent ML services (`app/services/`)
  - Configured with custom logging (`app/logger.py`)

## How to Run Locally

### Prerequisites
- Python 3.11+
- pip

### Setup
1. Clone the repository and navigate to the project root (`ml-service/`).
2. Create a virtual environment (optional but recommended):
   ```bash
   python -m venv venv
   # On Windows: venv\Scripts\activate
   # On Linux/macOS: source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the development server:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
5. View API documentation at: [http://localhost:8000/docs](http://localhost:8000/docs)

## How to Run Using Docker

1. Build the Docker image:
   ```bash
   docker build -t ml-service .
   ```
2. Run the Docker container:
   ```bash
   docker run -d -p 8000:8000 --name ml-service-container ml-service
   ```
3. View API documentation at: [http://localhost:8000/docs](http://localhost:8000/docs)

## Example API Requests

### 1. Smart House Allotment
Provides balanced clustering where each student receives exactly 5 houses.
**Endpoint:** `POST /api/v1/cluster-houses`

**Request Body:**
```json
{
  "students": 2,
  "houses": [
    {"id": "H1", "lat": 19.99, "lng": 73.78},
    {"id": "H2", "lat": 19.98, "lng": 73.77},
    {"id": "H3", "lat": 19.97, "lng": 73.76},
    {"id": "H4", "lat": 19.96, "lng": 73.75},
    {"id": "H5", "lat": 19.95, "lng": 73.74},
    {"id": "H6", "lat": 19.94, "lng": 73.73},
    {"id": "H7", "lat": 19.93, "lng": 73.72},
    {"id": "H8", "lat": 19.92, "lng": 73.71},
    {"id": "H9", "lat": 19.91, "lng": 73.70},
    {"id": "H10", "lat": 19.90, "lng": 73.69}
  ]
}
```

**Response:**
```json
{
  "clusters": {
    "0": ["H1", "H2", "H3", "H4", "H5"],
    "1": ["H6", "H7", "H8", "H9", "H10"]
  }
}
```

### 2. Health Risk Detection
Evaluates health risk based on systolic blood pressure.
**Endpoint:** `POST /api/v1/risk-detection`

**Request Body:**
```json
{
  "bp": "150/90"
}
```

**Response:**
```json
{
  "risk": "HIGH"
}
```

### 3. Visit Route Optimization
Computes the optimal visiting order for a set of assigned houses using a Nearest Neighbor TSP heuristic.
**Endpoint:** `POST /api/v1/optimize-route`

**Request Body:**
```json
{
  "houses": [
    {"id": "H1", "lat": 19.99, "lng": 73.78},
    {"id": "H2", "lat": 19.98, "lng": 73.77},
    {"id": "H3", "lat": 19.97, "lng": 73.76}
  ]
}
```

**Response:**
```json
{
  "route": ["H1", "H3", "H2"]
}
```

### 4. Health Check
Verifies that the microservice is operational.
**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "ok",
  "service": "ml-service"
}
```

## How Node.js Backend Should Call the ML Endpoints
The Node.js backend can use an HTTP client like `axios` or `node-fetch` to communicate with the ML Service. Ensure that the correct URL is targeted, e.g., `http://localhost:8000/api/v1/cluster-houses`. Handle non-200 responses appropriately as the ML service utilizes standard HTTP status codes (e.g., 400 for validation errors, 500 for internal errors).
