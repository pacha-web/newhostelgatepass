const db = require('./db');

exports.createGatePass = (data, callback) => {
  const sql = 'INSERT INTO gate_pass SET ?';
  db.query(sql, data, callback);
};

exports.updateGatePassStatus = (id, status, callback) => {
  const sql = 'UPDATE gate_pass SET status = ? WHERE id = ?';
  db.query(sql, [status, id], callback);
};

exports.getApprovedGatePasses = callback => {
  const sql = 'SELECT * FROM gate_pass WHERE status = "approved"';
  db.query(sql, callback);
};

exports.insertInOutLog = (student_id, status, callback) => {
  const sql = 'INSERT INTO logs (student_id, status, timestamp) VALUES (?, ?, NOW())';
  db.query(sql, [student_id, status], callback);
};

exports.getHistory = callback => {
  const sql = 'SELECT * FROM logs ORDER BY timestamp DESC';
  db.query(sql, callback);
};
