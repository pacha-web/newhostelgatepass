const db = require('../models/db');

exports.getAllStudents = (req, res) => {
  const query = 'SELECT * FROM students';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Error fetching students:', err);
      return res.status(500).json({ error: 'Failed to fetch students' });
    }

    const updatedResults = results.map(student => {
      if (student.profileImage && !student.profileImage.startsWith('/uploads/')) {
        student.profileImage = `/uploads/${student.profileImage}`;
      }
      return student;
    });

    res.json(updatedResults);
  });
};

exports.addStudent = (req, res) => {
  const {
    name,
    dob,
    department,
    address,
    phone,
    gender,
    guardianName,
    guardianPhNo,
    username,
    password
  } = req.body;

  const profileImage = req.file ? req.file.filename : null;

  const query = `
    INSERT INTO students
    (name, dob, department, address, phone, gender, guardianName, guardianPhNo, username, password, profileImage)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

  db.query(
    query,
    [name, dob, department, address, phone, gender, guardianName, guardianPhNo, username, password, profileImage],
    (err, result) => {
      if (err) {
        console.error('Error adding student:', err);
        return res.status(500).json({ error: 'Failed to add student' });
      }
      res.json({ message: 'Student added successfully', studentId: result.insertId });
    }
  );
};

exports.loginStudent = (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ message: 'Username and password are required' });
  }

  const query = 'SELECT * FROM students WHERE username = ? AND password = ?';

  db.query(query, [username, password], (err, results) => {
    if (err) {
      console.error('Login error:', err);
      return res.status(500).json({ error: 'Database error during login' });
    }

    if (results.length === 0) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    const student = results[0];
    delete student.password; // Remove sensitive info before sending

    res.status(200).json({ message: 'Login successful', student });
  });
};
const model = require('../models/gatePassModel');

exports.requestGatePass = (req, res) => {
  const data = req.body;
  model.insertGatePassRequest(data, (err, result) => {
    if (err) {
      console.error('Error submitting gate pass:', err);
      return res.status(500).json({ error: 'Failed to submit request' });
    }
    res.json({ message: 'Gate pass request submitted', id: result.insertId });
  });
};
