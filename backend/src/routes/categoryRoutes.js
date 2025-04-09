const express = require('express');
const router = express.Router();
const { auth, isAdmin } = require('../middlewares/auth');
const categoryController = require('../controllers/categoryController');
const { body } = require('express-validator');

// Validation des données
const validateCategory = [
  body('nom').trim().notEmpty().withMessage('Le nom de la catégorie est requis'),
  body('description').optional().trim(),
  body('parentCategory').optional().isMongoId().withMessage('ID de catégorie parent invalide')
];

// Routes publiques
router.get('/', categoryController.getCategories);
router.get('/:id', categoryController.getCategoryById);

// Routes protégées (Admin)
router.post('/', auth, isAdmin, validateCategory, categoryController.createCategory);
router.put('/:id', auth, isAdmin, validateCategory, categoryController.updateCategory);
router.delete('/:id', auth, isAdmin, categoryController.deleteCategory);

module.exports = router; 