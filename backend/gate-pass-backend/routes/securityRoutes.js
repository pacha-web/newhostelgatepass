const express = require('express');
const router = express.Router();
const controller = require('../controllers/securityController');

router.post('/scan', controller.scanQR);
router.get('/history', controller.viewHistory);

module.exports = router;
