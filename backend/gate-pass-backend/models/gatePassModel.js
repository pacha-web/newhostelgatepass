const db = require('./db');

// Get all gate pass requests
exports.getAllRequests = (callback) => {
  const query = 'SELECT * FROM gate_pass_requests';
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
