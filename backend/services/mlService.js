const axios = require('axios');

const mlClient = axios.create({
  baseURL: process.env.ML_API_URL,
  timeout: 30000,
  headers: { 'Content-Type': 'application/json' },
});

/**
 * Call ML risk-detection endpoint.
 * @param {Object} patientData - patient record data
 * @returns {Promise<Object>} ML response data
 */
const detectRisk = async (patientData) => {
  try {
    const response = await mlClient.post('/api/v1/risk-detection', patientData);
    return response.data;
  } catch (error) {
    console.warn(`ML Risk Detection failed (${error.message}). Using JS fallback.`);
    
    // JS Fallback: basic risk calculations
    let hypertension = 'normal';
    if (patientData.bp) {
      const [sys, dia] = patientData.bp.split('/').map(Number);
      if (sys >= 140 || dia >= 90) hypertension = 'high';
      else if (sys >= 120 || dia >= 80) hypertension = 'moderate';
    }

    let diabetes = 'normal';
    if (patientData.blood_sugar) {
      if (patientData.blood_sugar >= 140) diabetes = 'high';
      else if (patientData.blood_sugar >= 100) diabetes = 'moderate';
    }

    let obesity = 'normal';
    if (patientData.weight && patientData.height) {
      const bmi = patientData.weight / Math.pow(patientData.height / 100, 2);
      if (bmi >= 30) obesity = 'high';
      else if (bmi >= 25) obesity = 'moderate';
    }

    const hasHigh = [hypertension, diabetes, obesity].includes('high');
    const overallRisk = hasHigh ? 'HIGH' : 'LOW';

    return { hypertension, diabetes, obesity, overallRisk };
  }
};

/**
 * Call ML cluster-houses endpoint.
 * ML expects: { students: int, houses: [{ id, lat, lng }] }
 * ML returns: { clusters: { "0": ["houseId1", ...], "1": [...] } }
 * @param {number} studentCount - number of students
 * @param {Array} houses - list of house objects with id, lat, lng
 * @returns {Promise<Object>} ML clustering result
 */
const clusterHouses = async (studentCount, houses) => {
  try {
    const response = await mlClient.post('/api/v1/cluster-houses', {
      students: studentCount,
      houses: houses,
    });
    return response.data;
  } catch (error) {
    console.warn(`ML Service failed (${error.message}). Using JS fallback clustering.`);
    
    // JS Fallback: Coordinate-based balanced distribution
    const clusters = {};
    for (let i = 0; i < studentCount; i++) {
      clusters[i.toString()] = [];
    }

    // Sort houses roughly by geographic location (sum of lat/lng)
    const sortedHouses = [...houses].sort((a, b) => (a.lat + a.lng) - (b.lat + b.lng));

    // Assign up to 5 houses per student greedily
    let houseIdx = 0;
    for (let s = 0; s < studentCount; s++) {
      const clusterId = s.toString();
      for (let i = 0; i < 5; i++) {
        if (houseIdx < sortedHouses.length) {
          clusters[clusterId].push(sortedHouses[houseIdx].id);
          houseIdx++;
        }
      }
    }

    // Assign any remaining houses round-robin
    while (houseIdx < sortedHouses.length) {
      const clusterId = (houseIdx % studentCount).toString();
      clusters[clusterId].push(sortedHouses[houseIdx].id);
      houseIdx++;
    }

    return { clusters };
  }
};

module.exports = { detectRisk, clusterHouses };
