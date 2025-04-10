const jwt = require('jsonwebtoken');
const User = require('../models/User');

/**
 * Middleware to authenticate users
 * Verifies the JWT token and attaches the user to the request object
 */
const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = await User.findById(decoded.id).select('-password');
      next();
    } catch (error) {
      res.status(401).json({
        success: false,
        error: 'Not authorized'
      });
    }
  }

  if (!token) {
    res.status(401).json({
      success: false,
      error: 'Not authorized, no token'
    });
  }
};

const admin = (req, res, next) => {
  if (req.user && req.user.role === 'Admin') {
    next();
  } else {
    res.status(403).json({
      success: false,
      error: 'Not authorized as admin'
    });
  }
};

module.exports = {
  protect,
  admin
}; 