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
      console.log('Token reçu:', token);
      
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      console.log('Token décodé:', decoded);
      
      // Utiliser decoded.userId au lieu de decoded.id
      req.user = await User.findById(decoded.userId).select('-password');
      console.log('Utilisateur trouvé:', req.user ? req.user.email : 'Non trouvé', 'Rôle:', req.user ? req.user.role : 'Non défini');
      
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: 'User not found'
        });
      }
      
      next();
    } catch (error) {
      console.error('Token verification error:', error);
      res.status(401).json({
        success: false,
        error: 'Not authorized'
      });
    }
  } else {
    res.status(401).json({
      success: false,
      error: 'Not authorized, no token'
    });
  }
};

const admin = (req, res, next) => {
  console.log('Vérification du rôle admin. Utilisateur:', req.user ? req.user.email : 'Non défini', 'Rôle:', req.user ? req.user.role : 'Non défini');
  
  if (req.user && req.user.role === 'Admin') {
    next();
  } else {
    console.error('Admin check failed. User role:', req.user ? req.user.role : 'No user');
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