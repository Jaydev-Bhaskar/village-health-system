// Validation helpers — return error message or null if valid

const validateEmail = (email) => {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email) ? null : 'Invalid email format';
};

const validateRequired = (fields, body) => {
  const missing = fields.filter((f) => !body[f] || String(body[f]).trim() === '');
  if (missing.length > 0) {
    return `Missing required fields: ${missing.join(', ')}`;
  }
  return null;
};

const validateCoordinates = (lat, lng) => {
  const latitude = parseFloat(lat);
  const longitude = parseFloat(lng);
  if (isNaN(latitude) || latitude < -90 || latitude > 90) return 'Invalid latitude';
  if (isNaN(longitude) || longitude < -180 || longitude > 180) return 'Invalid longitude';
  return null;
};

module.exports = { validateEmail, validateRequired, validateCoordinates };
