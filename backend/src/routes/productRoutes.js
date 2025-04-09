const express = require('express');
const router = express.Router();
const { auth, isAdmin } = require('../middlewares/auth');
const productController = require('../controllers/productController');
const { body } = require('express-validator');

// Validation des données
const validateProduct = [
  body('nom').trim().notEmpty().withMessage('Le nom du produit est requis'),
  body('description').trim().notEmpty().withMessage('La description est requise'),
  body('prix').isFloat({ min: 0 }).withMessage('Le prix doit être un nombre positif'),
  body('prixPromo').optional().isFloat({ min: 0 }).withMessage('Le prix promo doit être un nombre positif'),
  body('discount').optional().isInt({ min: 0, max: 100 }).withMessage('La réduction doit être entre 0 et 100'),
  body('images').isArray({ min: 1 }).withMessage('Au moins une image est requise'),
  body('stock').isInt({ min: 0 }).withMessage('Le stock doit être un nombre positif'),
  body('categoryId').isMongoId().withMessage('ID de catégorie invalide')
];

const validateReview = [
  body('note').isInt({ min: 1, max: 5 }).withMessage('La note doit être entre 1 et 5'),
  body('commentaire').trim().notEmpty().withMessage('Le commentaire est requis')
];

// Routes publiques
router.get('/', productController.getProducts);
router.get('/search', productController.searchProducts);
router.get('/:id', productController.getProductById);

// Routes protégées (Authentifiées)
router.post('/:id/review', auth, validateReview, productController.addReview);

// Routes protégées (Admin)
router.post('/', auth, isAdmin, validateProduct, productController.createProduct);
router.put('/:id', auth, isAdmin, validateProduct, productController.updateProduct);

module.exports = router; 