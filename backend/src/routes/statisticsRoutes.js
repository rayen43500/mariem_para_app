const express = require('express');
const router = express.Router();
const statisticsController = require('../controllers/statisticsController');
const auth = require('../middleware/auth');

// Middleware pour vérifier que l'utilisateur a un rôle autorisé
const checkRole = (roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ 
        message: 'Accès non autorisé. Rôle requis: ' + roles.join(', ') 
      });
    }
    next();
  };
};

// Route pour obtenir les statistiques générales
// GET /api/statistics/general
router.get('/general', auth, statisticsController.getGeneralStats);

// Route pour obtenir les produits les plus vendus
// GET /api/statistics/best-sellers
router.get('/best-sellers', auth, statisticsController.getBestSellingProducts);

// Route pour obtenir les ventes par catégorie
// GET /api/statistics/sales-by-category
router.get('/sales-by-category', auth, statisticsController.getSalesByCategory);

module.exports = router; 