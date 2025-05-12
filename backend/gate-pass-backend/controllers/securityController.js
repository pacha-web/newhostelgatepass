const model = require('../models/gatePassModel');

exports.scanQR = (req, res) => {
  const { student_id, status } = req.body; // status = "in" or "out"
  model.insertInOutLog(student_id, status, (err) => {
    if (err) return res.status(500).send(err);
    res.send({ message: `Marked ${status}` });
  });
};

exports.viewHistory = (req, res) => {
  model.getHistory((err, logs) => {
    if (err) return res.status(500).send(err);
    res.send(logs);
  });
};
