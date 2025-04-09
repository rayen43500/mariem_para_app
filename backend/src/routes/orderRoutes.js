const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const validateObjectId = require('../middleware/validateObjectId');

// Appliquer le rate limiting à toutes les routes
router.use(orderController.orderLimiter);

// Routes protégées par authentification
router.use(auth);

// Routes pour les clients
router.post('/', orderController.createOrder);
router.get('/', orderController.getUserOrders);

// Routes pour les administrateurs
router.get('/:id', admin, validateObjectId('id'), orderController.getOrder);
router.put('/:id', admin, validateObjectId('id'), orderController.updateOrderStatus);

module.exports = router; 