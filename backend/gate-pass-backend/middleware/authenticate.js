const jwt = require("jsonwebtoken");
const Student = require("../models/studentModel");

const authenticate = async (req, res, next) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "");
    if (!token) {
      return res.status(401).json({ message: "No token provided" });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const student = await Student.findById(decoded.id);

    if (!student) {
      return res.status(401).json({ message: "Student not found" });
    }

    req.user = student; // 🔴 This is important
    next();
  } catch (err) {
    return res.status(401).json({ message: "Unauthorized", error: err.message });
  }
};

module.exports = authenticate;
