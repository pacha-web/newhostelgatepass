const express = require('express');
const router = express.Router();
const controller = require('../controllers/adminController');

router.put('/approve/:id', controller.approveGatePass);
router.get('/approved', controller.viewApproved);

module.exports = router;
