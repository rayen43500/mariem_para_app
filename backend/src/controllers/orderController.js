const Order = require('../models/Order');
const Cart = require('../models/Cart');
const { rateLimit } = require('express-rate-limit');

// Configuration du rate limiting
const orderLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 50 // limite chaque IP à 50 requêtes par fenêtre
});

// Créer une commande à partir du panier
exports.createOrder = async (req, res) => {
  try {
    const { adresseLivraison } = req.body;

    // Récupérer le panier de l'utilisateur
    const cart = await Cart.findOne({ userId: req.user.id }).populate('produits.produitId');
    if (!cart || cart.produits.length === 0) {
      return res.status(400).json({ message: 'Panier vide' });
    }

    // Créer la commande
    const order = new Order({
      userId: req.user.id,
      produits: cart.produits.map(item => ({
        produitId: item.produitId._id,
        quantité: item.quantité,
        prixUnitaire: item.produitId.prix
      })),
      adresseLivraison,
      total: cart.totalPrix
    });

    await order.save();

    // Vider le panier
    await Cart.findOneAndUpdate(
      { userId: req.user.id },
      { $set: { produits: [], totalPrix: 0 } }
    );

    // TODO: Envoyer un email de confirmation
    // TODO: Intégrer avec le système de paiement

    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Récupérer les commandes de l'utilisateur
exports.getUserOrders = async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user.id })
      .populate('produits.produitId', 'nom images')
      .sort({ dateCommande: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Récupérer une commande spécifique (admin)
exports.getOrder = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('produits.produitId', 'nom images')
      .populate('userId', 'nom email');

    if (!order) {
      return res.status(404).json({ message: 'Commande non trouvée' });
    }

    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Mettre à jour le statut d'une commande (admin)
exports.updateOrderStatus = async (req, res) => {
  try {
    const { statut } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ message: 'Commande non trouvée' });
    }

    order.statut = statut;
    if (statut === 'Expédiée') {
      order.dateLivraison = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 jours
    }

    await order.save();
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Assigner un livreur à une commande (admin)
exports.assignDeliveryPerson = async (req, res) => {
  try {
    const { deliveryPersonId } = req.body;
    
    if (!deliveryPersonId) {
      return res.status(400).json({ message: 'ID du livreur requis' });
    }
    
    // Vérifier si le livreur existe
    const DeliveryPerson = require('../models/DeliveryPerson');
    const deliveryPerson = await DeliveryPerson.findById(deliveryPersonId);
    
    if (!deliveryPerson) {
      return res.status(404).json({ message: 'Livreur non trouvé' });
    }
    
    // Mettre à jour la commande
    const order = await Order.findById(req.params.id);
    
    if (!order) {
      return res.status(404).json({ message: 'Commande non trouvée' });
    }
    
    // Assigner le livreur à la commande
    order.deliveryPersonId = deliveryPerson._id;
    
    // Si la commande est en statut "En attente", la passer en statut "Expédiée"
    if (order.statut === 'En attente') {
      order.statut = 'Expédiée';
      order.dateLivraison = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000); // Livraison dans 2 jours
    }
    
    await order.save();
    
    // Ajouter la commande aux commandes assignées du livreur
    if (!deliveryPerson.assignedOrders.includes(order._id)) {
      deliveryPerson.assignedOrders.push(order._id);
      await deliveryPerson.save();
    }
    
    res.json({
      message: 'Livreur assigné avec succès',
      order
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Exporter le middleware de rate limiting
exports.orderLimiter = orderLimiter; 