const House = require('../models/House');
const { validateRequired, validateCoordinates } = require('../middleware/validate');

/**
 * Haversine distance formula — returns distance in meters.
 */
const haversineDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371000; // Earth radius in metres
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

const DISTANCE_THRESHOLD_M = 30;

// POST /api/visit/verify
const verifyVisit = async (req, res) => {
  try {
    const reqError = validateRequired(['houseId', 'latitude', 'longitude'], req.body);
    if (reqError) return res.status(400).json({ message: reqError });

    const coordError = validateCoordinates(req.body.latitude, req.body.longitude);
    if (coordError) return res.status(400).json({ message: coordError });

    const house = await House.findById(req.body.houseId);
    if (!house) return res.status(404).json({ message: 'House not found' });

    const distance = haversineDistance(
      parseFloat(req.body.latitude),
      parseFloat(req.body.longitude),
      house.latitude,
      house.longitude
    );

    if (distance > DISTANCE_THRESHOLD_M) {
      return res.status(400).json({
        message: 'You are not near the assigned house',
        distance: Math.round(distance),
      });
    }

    res.status(200).json({
      message: 'Visit verified',
      distance: Math.round(distance),
      house,
    });
  } catch (err) {
    res.status(500).json({ message: 'Visit verification failed' });
  }
};

module.exports = { verifyVisit };
