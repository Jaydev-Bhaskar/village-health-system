from app.logger import logger

def determine_risk(request) -> dict:
    """
    Determine risk based on blood pressure, blood sugar, and BMI.
    Returns a dictionary of risk levels.
    """
    logger.info("Determining holistic risk score")
    
    risk_data = {
        "hypertension": "normal",
        "diabetes": "normal",
        "obesity": "normal",
        "overallRisk": "normal"
    }
    
    try:
        # Hypertension Risk
        if request.bp and '/' in request.bp:
            sys_str, dia_str = request.bp.split('/')
            sys = int(sys_str.strip())
            dia = int(dia_str.strip())
            if sys >= 160 or dia >= 100:
                risk_data["hypertension"] = "high"
            elif sys >= 140 or dia >= 90:
                risk_data["hypertension"] = "high"
            elif sys >= 120 or dia >= 80:
                risk_data["hypertension"] = "moderate"
                
        # Diabetes Risk
        if request.blood_sugar is not None:
            if request.blood_sugar >= 200:
                risk_data["diabetes"] = "high"
            elif request.blood_sugar >= 140:
                risk_data["diabetes"] = "moderate"
                
        # Obesity Risk
        if request.weight is not None and request.height is not None and request.height > 0:
            bmi = request.weight / ((request.height / 100) ** 2)
            if bmi >= 30:
                risk_data["obesity"] = "high"
            elif bmi >= 25:
                risk_data["obesity"] = "moderate"
                
        # Overall Risk Calculation
        if risk_data["hypertension"] == "high" or risk_data["diabetes"] == "high" or risk_data["obesity"] == "high":
            risk_data["overallRisk"] = "high"
        elif risk_data["hypertension"] == "moderate" or risk_data["diabetes"] == "moderate" or risk_data["obesity"] == "moderate":
            risk_data["overallRisk"] = "moderate"

        return risk_data
        
    except Exception as e:
        logger.error(f"Error during risk determination: {e}")
        # Return graceful defaults if error happens
        return risk_data
