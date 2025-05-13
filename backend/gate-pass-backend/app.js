// app.js
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const studentRoutes = require('./routes/studentRoutes');
const path = require('path');

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Serve static files (uploads)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ✅ Root test route
app.get('/', (req, res) => {
  res.send('🎉 API is running. Use /api/students to POST student data.');
});

// Use student routes
app.use('/api', studentRoutes);

module.exports = app;
