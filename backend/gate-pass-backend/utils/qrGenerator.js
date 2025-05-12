const QRCode = require('qrcode');
const fs = require('fs');
const path = require('path');

exports.generateQRCode = (id) => {
  const data = `http://localhost:5000/api/security/scan/${id}`;
  const filePath = path.join(__dirname, '../public/qrcodes/', `${id}.png`);
  QRCode.toFile(filePath, data, (err) => {
    if (err) console.error('QR Code Error:', err);
    else console.log('QR Code saved:', filePath);
  });
};
