const model = require('../models/gatePassModel');
const qr = require('../utils/qrGenerator');

exports.approveGatePass = (req, res) => {
  const id = req.params.id;
  model.updateGatePassStatus(id, 'Approved', (err) => {
    if (err) return res.status(500).send(err);
    res.send({ message: 'Gate pass approved' });
  });
};

exports.viewApproved = (req, res) => {
  model.getApprovedGatePasses((err, results) => {
    if (err) return res.status(500).send(err);
    res.send(results);
  });
};

exports.viewAllRequests = (req, res) => {
  model.getAllRequests((err, results) => {
    if (err) return res.status(500).send(err);
    res.send(results);
  });
};

