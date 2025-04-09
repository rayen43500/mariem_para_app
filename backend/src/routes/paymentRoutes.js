const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const validateObjectId = require('../middleware/validateObjectId');

// Appliquer le rate limiting à toutes les routes
router.use(paymentController.paymentLimiter);

// Routes nécessitant une authentification
router.use(auth);

// Route pour le traitement des paiements (client)
router.post('/', paymentController.processPayment);

// Routes pour l'administration (admin uniquement)
router.get('/:id', admin, validateObjectId('id'), paymentController.getPaymentDetails);
router.put('/:id/validate', admin, validateObjectId('id'), paymentController.validateCashPayment);
router.put('/:id/cancel', admin, validateObjectId('id'), paymentController.cancelPayment);

module.exports = router; 