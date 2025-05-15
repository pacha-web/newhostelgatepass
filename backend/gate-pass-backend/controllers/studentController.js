const db = require('../models/db');

exports.getAllStudents = (req, res) => {
  const query = 'SELECT * FROM students';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Error fetching students:', err);
      return res.status(500).json({ error: 'Failed to fetch students' });
    }

    // Ensure profileImage includes '/uploads/' prefix if not already
    const updatedResults = results.map(student => {
      if (student.profileImage && !student.profileImage.startsWith('/uploads/')) {
        student.profileImage = `/uploads/${student.profileImage}`;
      }
      return student;
    });

    res.json(updatedResults); // 🔥 Send flat array instead of { students: [...] }
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
