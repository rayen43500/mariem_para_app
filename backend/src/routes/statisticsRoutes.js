const express = require('express');
const router = express.Router();
const { check } = require('express-validator');
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

// Route pour créer une nouvelle statistique de test
// POST /api/statistics/tests
router.post('/tests', 
  auth,
  [
    check('testName', 'Le nom du test est requis').not().isEmpty(),
    check('testType', 'Le type de test est requis').not().isEmpty(),
    check('duration', 'La durée doit être un nombre positif').isNumeric().toFloat().custom(value => value >= 0),
    check('success', 'Le statut de réussite est requis').isBoolean(),
    check('module', 'Le module testé est requis').not().isEmpty()
  ],
  statisticsController.createTestStatistic
);

// Route pour récupérer toutes les statistiques avec filtrage possible
// GET /api/statistics/tests
router.get('/tests', auth, statisticsController.getAllTestStatistics);

// Route pour récupérer une statistique spécifique par ID
// GET /api/statistics/tests/:id
router.get('/tests/:id', auth, statisticsController.getTestStatisticById);

// Route pour mettre à jour une statistique
// PUT /api/statistics/tests/:id
router.put('/tests/:id', 
  auth,
  [
    check('duration', 'La durée doit être un nombre positif').optional().isNumeric().toFloat().custom(value => value >= 0),
    check('success', 'Le statut de réussite doit être un booléen').optional().isBoolean(),
    check('errorCount', 'Le nombre d\'erreurs doit être un nombre positif').optional().isNumeric().toInt().custom(value => value >= 0),
    check('warningCount', 'Le nombre d\'avertissements doit être un nombre positif').optional().isNumeric().toInt().custom(value => value >= 0)
  ],
  statisticsController.updateTestStatistic
);

// Route pour supprimer une statistique
// DELETE /api/statistics/tests/:id
router.delete('/tests/:id', 
  auth, 
  checkRole(['Admin', 'Developpeur']), 
  statisticsController.deleteTestStatistic
);

// Route pour obtenir des rapports agrégés
// GET /api/statistics/reports
router.get('/reports', auth, statisticsController.getTestStatisticsReports);

// Route pour comparer les performances entre deux périodes
// GET /api/statistics/compare
router.get('/compare', auth, statisticsController.compareTestPerformance);

module.exports = router; 