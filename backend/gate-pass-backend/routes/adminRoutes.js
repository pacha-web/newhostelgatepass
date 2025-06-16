const express = require('express');
const router = express.Router();
const controller = require('../controllers/adminController');
const model = require('../models/gatePassModel'); // ✅ Import added

router.put('/approve/:id', controller.approveGatePass);
router.get('/approved', controller.viewApproved);
router.get('/requests', controller.viewAllRequests);

// ✅ New route for status update
router.put('/requests/:id/status', (req, res) => {
  const id = req.params.id;
  const { status } = req.body;

  if (!['Approved', 'Rejected'].includes(status)) {
    return res.status(400).json({ error: 'Invalid status' });
  }

  model.updateGatePassStatus(id, status, (err) => {
    if (err) return res.status(500).json({ error: 'Update failed' });
    res.json({ message: `Status updated to ${status}` });
  });
});

module.exports = router;
