const axios = require('axios');

const mlClient = axios.create({
  baseURL: process.env.ML_API_URL,
  timeout: 15000,
  headers: { 'Content-Type': 'application/json' },
});

/**
 * Call ML risk-detection endpoint.
 * @param {Object} patientData - patient record data
 * @returns {Promise<Object>} ML response data
 */
const detectRisk = async (patientData) => {
  const response = await mlClient.post('/api/v1/risk-detection', patientData);
  return response.data;
};

/**
 * Call ML cluster-houses endpoint.
 * @param {Array} houses - list of house objects with lat/lng
 * @returns {Promise<Object>} ML clustering result
 */
const clusterHouses = async (houses) => {
  const response = await mlClient.post('/api/v1/cluster-houses', { houses });
  return response.data;
};

module.exports = { detectRisk, clusterHouses };
