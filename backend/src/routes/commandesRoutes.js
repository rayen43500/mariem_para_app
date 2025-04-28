const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { protect } = require('../middleware/auth');
const { rateLimit } = require('express-rate-limit');

// Debug middleware - log all incoming requests
router.use((req, res, next) => {
  console.log(`[COMMANDES API] Request received: ${req.method} ${req.originalUrl}`);
  next();
});

// Rate limiter pour les endpoints commandes
const commandesLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 60, // Limite à 60 requêtes par fenêtre
  message: 'Trop de requêtes, veuillez réessayer plus tard.'
});

// Appliquer le rate limiting à toutes les routes
router.use(commandesLimiter);

// Routes protégées par authentification
router.use(protect);

// Route pour créer une commande
router.post('/', orderController.createOrder);

// Route pour récupérer les commandes de l'utilisateur
router.get('/mes-commandes', orderController.getUserOrders);
// Route principale pour récupérer les commandes de l'utilisateur (pour la compatibilité avec le client)
router.get('/', orderController.getUserOrders);

// Route API pour l'application mobile - retourne des données formatées pour mobile
router.get('/mobile/mes-commandes', orderController.getMobileUserOrders);
console.log('Route mobile enregistrée: /mobile/mes-commandes');

// Route API pour l'application mobile - détails d'une commande
router.get('/mobile/:id', orderController.getMobileOrderDetails);
console.log('Route mobile détails enregistrée: /mobile/:id');

// Route pour récupérer les détails d'une commande
router.get('/:id', orderController.getOrder);

// Route pour annuler une commande
router.put('/:id/annuler', orderController.updateOrderStatus);

module.exports = router; 