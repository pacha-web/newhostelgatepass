const jwt = require("jsonwebtoken");
const db = require("../models/db");

const authenticate = async (req, res, next) => {
  try {
    const token = req.header("Authorization")?.replace("Bearer ", "");
    if (!token) {
      return res.status(401).json({ message: "No token provided" });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET); // Must contain student.id

    const query = "SELECT * FROM students WHERE id = ?";
    db.query(query, [decoded.id], (err, results) => {
      if (err) {
        console.error("DB error:", err);
        return res.status(500).json({ message: "DB error" });
      }

      if (results.length === 0) {
        return res.status(401).json({ message: "Student not found" });
      }

      req.user = results[0]; // ✅ Now req.user.id will work
      next();
    });
  } catch (err) {
    return res.status(401).json({ message: "Unauthorized", error: err.message });
  }
};

module.exports = authenticate;
