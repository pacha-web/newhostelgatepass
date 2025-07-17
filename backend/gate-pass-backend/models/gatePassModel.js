const db = require('./db');

// Get all gate pass requests
// Get all gate pass requests with student details
exports.getAllRequests = (callback) => {
  const query = `
    SELECT 
      gpr.id, gpr.name AS studentName, gpr.roll, gpr.department, gpr.reason,
      gpr.departureTime, gpr.returnTime, gpr.status, gpr.createdAt,
      s.profileImage
    FROM gate_pass_requests gpr
    LEFT JOIN students s ON TRIM(LOWER(gpr.roll)) = TRIM(LOWER(s.roll))
    ORDER BY gpr.createdAt DESC
  `;
  db.query(query, (err, results) => {
    if (err) return callback(err);
    callback(null, results);
  });
};




// Update status
exports.updateGatePassStatus = (id, status, callback) => {
  const query = 'UPDATE gate_pass_requests SET status = ? WHERE id = ?';
  db.query(query, [status, id], (err, result) => {
    if (err) return callback(err);
    callback(null, result);
  });
};


// Get only approved requests
exports.getApprovedGatePasses = (callback) => {
  const query = 'SELECT * FROM gate_pass_requests WHERE status = "Approved"';
  db.query(query, (err, results) => {
    if (err) return callback(err);
    callback(null, results);
  });
};

// Insert a new request
exports.insertGatePassRequest = (data, callback) => {
  const {
    name,
    roll,
    department,
    reason,
    departureTime,
    returnTime,
    status = 'Pending'
  } = data;

  const query = `
    INSERT INTO gate_pass_requests (name, roll, department, reason, departureTime, returnTime, status)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;

  const values = [name, roll, department, reason, departureTime, returnTime, status];

  db.query(query, values, (err, result) => {
    if (err) return callback(err);
    callback(null, result);
  });
};
// gatePassModel.js
exports.insertGatePassRequest = (data, callback) => {
  const { student_id, name, roll, department, reason, departureTime, returnTime } = data;
  const query = `
    INSERT INTO gate_pass_requests
      (student_id, name, roll, department, reason, departureTime, returnTime, status)
    VALUES (?, ?, ?, ?, ?, ?, ?, 'Pending')
  `;
  db.query(query, [student_id, name, roll, department, reason, departureTime, returnTime], (err, result) => {
    if (err) return callback(err);
    callback(null, result);
  });
};
