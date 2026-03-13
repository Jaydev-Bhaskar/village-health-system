from app.logger import logger

def determine_risk(bp: str) -> str:
    """
    Determine risk based on blood pressure string (e.g., '150/90')
    """
    logger.info(f"Determine risk for blood pressure: {bp}")
    try:
        systolic_str, diastolic_str = bp.split('/')
        systolic = int(systolic_str.strip())
        diastolic = int(diastolic_str.strip())  
        
        if systolic >= 140:
            return "HIGH"
        elif systolic >= 120:
            return "MODERATE"
        else:
            return "LOW"
    except Exception as e:
        logger.error(f"Error parsing blood pressure {bp}: {e}")
        raise ValueError(f"Invalid blood pressure format: {bp}. Expected format 'systolic/diastolic'")
