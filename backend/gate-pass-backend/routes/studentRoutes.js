const express = require('express');
const multer = require('multer');
const path = require('path');
const router = express.Router();
const db = require('../models/db');

// Multer setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) =>
    cb(null, Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage });

// Add student
router.post('/add-student', upload.single('profileImage'), (req, res) => {
  console.log("POST /api/add-student hit");

  const {
    name, dob, department, address, phone,
    gender, guardianName, guardianPhNo, username, password
  } = req.body;

  const profileImage = req.file ? `/uploads/${req.file.filename}` : null;

  const   query  = `INSERT INTO students 
    (name, dob, department, address, phone, gender, guardianName, guardianPhNo, username, password, profileImage)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

  db.query(query,
    [name, dob, department, address, phone, gender, guardianName, guardianPhNo, username, password, profileImage],
    (err, result) => {
      if (err) {
        console.error("Insert error:", err);
        return res.status(500).json({ error: "Database error" });
      }
      res.status(200).json({ message: "Student added successfully" });
    }
  );
});

// Get all students
router.get('/students', (req, res) => {
  db.query('SELECT * FROM students', (err, results) => {
    if (err) {
      return res.status(500).json({ error: "Database error" });
    }
    res.status(200).json(results);
  });
});
router.delete('/students/:id', (req, res) => {
  const studentId = req.params.id;
  const query = 'DELETE FROM students WHERE id = ?';

  db.query(query, [studentId], (err, result) => {
    if (err) {
      console.error('Error deleting student:', err);
      return res.status(500).json({ error: 'Failed to delete student' });
    }
    res.json({ message: 'Student deleted successfully' });
  });
});

module.exports = router;
