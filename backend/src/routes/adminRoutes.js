const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const validateObjectId = require('../middleware/validateObjectId');

// Toutes les routes nécessitent une authentification et des privilèges admin
router.use(auth);
router.use(admin);

// Routes pour gérer les livreurs
router.post('/delivery-persons', adminController.createDeliveryPerson);
router.get('/delivery-persons', adminController.getAllDeliveryPersons);
router.get('/delivery-persons/:id', validateObjectId('id'), adminController.getDeliveryPerson);
router.put('/delivery-persons/:id', validateObjectId('id'), adminController.updateDeliveryPerson);
router.put('/delivery-persons/:id/reset-password', validateObjectId('id'), adminController.resetDeliveryPersonPassword);
router.delete('/delivery-persons/:id', validateObjectId('id'), adminController.deleteDeliveryPerson);
router.get('/delivery-stats', adminController.getDeliveryStats);

module.exports = router; 