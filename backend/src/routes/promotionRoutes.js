const express = require('express');
const router = express.Router();
const promotionController = require('../controllers/promotionController');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const validateObjectId = require('../middleware/validateObjectId');

// Appliquer le rate limiting à toutes les routes
router.use(promotionController.promotionLimiter);

// Routes publiques
router.get('/product/:productId', validateObjectId('productId'), promotionController.getProductPromotions);
router.post('/apply-code', promotionController.applyPromoCode);

// Routes nécessitant authentification et droits admin
router.use(auth);
router.use(admin);

// Routes admin pour la gestion des promotions
router.post('/', promotionController.createPromotion);
router.get('/', promotionController.getAllPromotions);
router.get('/:id', validateObjectId('id'), promotionController.getPromotionById);
router.put('/:id', validateObjectId('id'), promotionController.updatePromotion);
router.delete('/:id', validateObjectId('id'), promotionController.deletePromotion);

module.exports = router; 