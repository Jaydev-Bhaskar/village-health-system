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
    const error = validateRequired(['name', 'password'], req.body);
    if (error) return res.status(400).json({ message: error });

    // Email is optional - validate only if provided
    if (req.body.email) {
      const emailError = validateEmail(req.body.email);
      if (emailError) return res.status(400).json({ message: emailError });

      const existing = await User.findOne({ email: req.body.email.toLowerCase() });
      if (existing) return res.status(400).json({ message: 'Email already registered' });
    }

    // Check if studentId already exists
    if (req.body.studentId) {
      const existingStudent = await User.findOne({ studentId: req.body.studentId });
      if (existingStudent) return res.status(400).json({ message: 'Student ID already registered' });
    }

    const userData = {
      name: req.body.name.trim(),
      password: req.body.password,
      studentId: req.body.studentId || undefined,
      role: req.body.role === 'admin' ? 'admin' : 'student',
    };

    // Only set email if provided
    if (req.body.email) {
      userData.email = req.body.email.toLowerCase().trim();
    }

    const user = await User.create(userData);

    const token = signToken(user._id);
    res.status(201).json({
      token,
      studentId: user.studentId || user._id,
      name: user.name,
      role: user.role,
    });
  } catch (err) {
    console.error('Registration error:', err.message);
    res.status(500).json({ message: 'Server error during registration' });
  }
};

// POST /api/auth/login
// Supports login via studentId OR email
const login = async (req, res) => {
  try {
    const { identifier, email, password } = req.body;
    
    // Support both 'identifier' (new) and 'email' (legacy) fields
    const loginId = identifier || email;
    
    if (!loginId || !password) {
      return res.status(400).json({ message: 'Please provide ID/email and password' });
    }

    // Try to find user by studentId first, then by email
    let user = await User.findOne({ studentId: loginId }).select('+password');
    if (!user) {
      user = await User.findOne({ email: loginId.toLowerCase() }).select('+password');
    }
    
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

    const token = signToken(user._id);
    res.status(200).json({
      token,
      studentId: user.studentId || user._id,
      name: user.name,
      role: user.role,
    });
  } catch (err) {
    console.error('Login error:', err.message);
    res.status(500).json({ message: 'Server error during login' });
  }
};

// POST /api/auth/change-password
const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: 'Please provide current and new password' });
    }

    if (newPassword.length < 4) {
      return res.status(400).json({ message: 'New password must be at least 4 characters' });
    }

    const user = await User.findById(req.user._id).select('+password');
    if (!user) return res.status(404).json({ message: 'User not found' });

    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) return res.status(401).json({ message: 'Current password is incorrect' });

    user.password = newPassword;
    await user.save();

    res.status(200).json({ message: 'Password changed successfully' });
  } catch (err) {
    console.error('Change password error:', err.message);
    res.status(500).json({ message: 'Failed to change password' });
  }
};

module.exports = { register, login, changePassword };
