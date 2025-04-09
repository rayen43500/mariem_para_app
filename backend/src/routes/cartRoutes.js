const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');
const auth = require('../middleware/auth');
const validateObjectId = require('../middleware/validateObjectId');

// Appliquer le rate limiting à toutes les routes du panier
router.use(cartController.cartLimiter);

// Routes protégées par authentification
router.use(auth);

// Obtenir le panier de l'utilisateur
router.get('/', cartController.getCart);

// Ajouter un produit au panier
router.post('/', cartController.addToCart);

// Mettre à jour la quantité d'un produit
router.put('/:produitId', validateObjectId('produitId'), cartController.updateCartItem);

// Supprimer un produit du panier
router.delete('/:produitId', validateObjectId('produitId'), cartController.removeFromCart);

// Vider le panier
router.delete('/', cartController.clearCart);

// Appliquer un code promo
router.post('/coupon', cartController.applyCoupon);

module.exports = router; 