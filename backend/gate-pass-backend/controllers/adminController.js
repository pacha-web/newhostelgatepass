const model = require('../models/gatePassModel');
const qr = require('../utils/qrGenerator');

exports.approveGatePass = (req, res) => {
  const id = req.params.id;
  model.updateGatePassStatus(id, 'approved', (err) => {
    if (err) return res.status(500).send(err);
    qr.generateQRCode(id); // Save QR in /public/qrcodes
    res.send({ message: 'Gate pass approved and QR generated' });
  });
};

exports.viewApproved = (req, res) => {
  model.getApprovedGatePasses((err, results) => {
    if (err) return res.status(500).send(err);
    res.send(results);
  });
};
