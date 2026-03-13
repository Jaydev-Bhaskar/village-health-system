const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { validateEmail, validateRequired } = require('../middleware/validate');

const signToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });

// POST /api/auth/register
const register = async (req, res) => {
  try {
    const error = validateRequired(['name', 'email', 'password'], req.body);
    if (error) return res.status(400).json({ message: error });

    const emailError = validateEmail(req.body.email);
    if (emailError) return res.status(400).json({ message: emailError });

    const existing = await User.findOne({ email: req.body.email.toLowerCase() });
    if (existing) return res.status(400).json({ message: 'Email already registered' });

    const user = await User.create({
      name: req.body.name.trim(),
      email: req.body.email.toLowerCase().trim(),
      password: req.body.password,
      studentId: req.body.studentId || undefined,
      role: req.body.role === 'admin' ? 'admin' : 'student',
    });

    const token = signToken(user._id);
    res.status(201).json({
      token,
      studentId: user._id,
      name: user.name,
      role: user.role,
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error during registration' });
  }
};

// POST /api/auth/login
const login = async (req, res) => {
  try {
    const error = validateRequired(['email', 'password'], req.body);
    if (error) return res.status(400).json({ message: error });

    const user = await User.findOne({ email: req.body.email.toLowerCase() }).select('+password');
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });

    const isMatch = await user.comparePassword(req.body.password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

    const token = signToken(user._id);
    res.status(200).json({
      token,
      studentId: user._id,
      name: user.name,
      role: user.role,
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error during login' });
  }
};

module.exports = { register, login };
