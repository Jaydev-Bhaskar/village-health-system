require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const mongoSanitize = require('express-mongo-sanitize');
const connectDB = require('./config/db');
const fs = require('fs');
const path = require('path');

// Route imports
const authRoutes = require('./routes/auth');
const studentRoutes = require('./routes/student');
const visitRoutes = require('./routes/visit');
const patientRoutes = require('./routes/patient');
const adminRoutes = require('./routes/admin');
const notificationRoutes = require('./routes/notification');

// Connect to MongoDB
connectDB();

const app = express();

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// ─── Security Middleware ───────────────────────────────────────────────────

// HTTP security headers
app.use(helmet());

// CORS — restrict to allowed origins from env
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map((o) => o.trim())
  : [];

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, Postman)
      if (!origin || allowedOrigins.length === 0 || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    credentials: true,
  })
);

// ─── Body Parsing ──────────────────────────────────────────────────────────

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// NoSQL injection sanitizer
app.use(mongoSanitize());

// ─── Routes ────────────────────────────────────────────────────────────────

app.use('/api/auth', authRoutes);
app.use('/api/student', studentRoutes);
app.use('/api/visit', visitRoutes);
app.use('/api/patient', patientRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/notifications', notificationRoutes);

// Health check
app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

// ─── Global Error Handler ──────────────────────────────────────────────────

// 404 handler
app.use((req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

// General error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  const status = err.statusCode || 500;
  res.status(status).json({
    message: err.message || 'Internal server error',
  });
});

// ─── Start Server ──────────────────────────────────────────────────────────

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Village Health API running on port ${PORT}`);
});

module.exports = app;
