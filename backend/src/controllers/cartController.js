const Cart = require('../models/Cart');
const Product = require('../models/Product');
const { rateLimit } = require('express-rate-limit');

// Configuration du rate limiting
const cartLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limite chaque IP à 100 requêtes par fenêtre
});

// Obtenir le panier de l'utilisateur
exports.getCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.user.id })
      .populate('produits.produitId', 'nom prix images stock');

    if (!cart) {
      return res.status(200).json({
        produits: [],
        totalPrix: 0,
        codePromo: null,
        réduction: 0
      });
    }

    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Ajouter un produit au panier
exports.addToCart = async (req, res) => {
  try {
    const { produitId, quantite } = req.body;
    if (!produitId || !quantite || quantite < 1) {
      return res.status(400).json({ message: 'ID du produit et quantité positive sont requis' });
    }

    // Vérifie si le produit existe
    const produit = await Product.findById(produitId);
    if (!produit) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    // Vérifie si le produit est disponible
    if (!produit.disponible) {
      return res.status(400).json({ message: 'Ce produit n\'est pas disponible actuellement' });
    }

    // Vérifie si la quantité demandée est disponible en stock
    if (produit.stock < quantite) {
      return res.status(400).json({ 
        message: `Stock insuffisant. Seulement ${produit.stock} unités disponibles.`,
        stockDisponible: produit.stock 
      });
    }

    // Trouver ou créer le panier de l'utilisateur
    let cart = await Cart.findOne({ userId: req.user.id });

    if (!cart) {
      // Créer un nouveau panier si l'utilisateur n'en a pas
      cart = new Cart({
        userId: req.user.id,
        produits: [],
        totalPrix: 0
      });
    }

    // Ajouter le produit au panier
    await cart.ajouterProduit(produitId, quantite, produit.prix);

    // Remplir les détails des produits pour la réponse
    await cart.populate('produits.produitId', 'nom prix images stock');
    
    res.status(200).json({
      message: 'Produit ajouté au panier avec succès',
      cart
    });
  } catch (error) {
    console.error('Erreur lors de l\'ajout au panier:', error);
    res.status(500).json({ message: 'Erreur serveur lors de l\'ajout au panier' });
  }
};

// Mettre à jour la quantité d'un produit
exports.updateCartItem = async (req, res) => {
  try {
    const { quantité } = req.body;
    const { produitId } = req.params;

    // Vérifier si le produit existe, est actif et a un stock suffisant
    const produit = await Product.findById(produitId);
    
    if (!produit) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }
    
    if (!produit.disponible) {
      return res.status(400).json({ message: 'Ce produit n\'est pas disponible actuellement' });
    }
    
    if (quantité > 0 && produit.stock < quantité) {
      return res.status(400).json({ 
        message: `Stock insuffisant. Seulement ${produit.stock} unité(s) disponible(s)`,
        disponible: produit.stock
      });
    }

    // Trouver le panier
    const cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      return res.status(404).json({ message: 'Panier non trouvé' });
    }

    // Mettre à jour la quantité
    const itemIndex = cart.produits.findIndex(item => item.produitId.toString() === produitId);
    if (itemIndex === -1) {
      return res.status(404).json({ message: 'Produit non trouvé dans le panier' });
    }

    if (quantité === 0) {
      await cart.supprimerProduit(produitId);
    } else {
      cart.produits[itemIndex].quantité = quantité;
      cart.produits[itemIndex].prixUnitaire = produit.prix;
      await cart.calculerTotal();
      await cart.save();
    }

    // Remplir les détails des produits pour la réponse
    await cart.populate('produits.produitId', 'nom prix images stock');
    res.json(cart);
  } catch (error) {
    console.error('Erreur lors de la mise à jour du panier:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Supprimer un produit du panier
exports.removeFromCart = async (req, res) => {
  try {
    const { produitId } = req.params;

    const cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      return res.status(404).json({ message: 'Panier non trouvé' });
    }

    await cart.supprimerProduit(produitId);
    
    // Remplir les détails des produits pour la réponse
    await cart.populate('produits.produitId', 'nom prix images stock');
    res.json(cart);
  } catch (error) {
    console.error('Erreur lors de la suppression du produit:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Vider le panier
exports.clearCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      return res.status(404).json({ message: 'Panier non trouvé' });
    }

    await cart.viderPanier();
    res.json({ 
      message: 'Panier vidé avec succès',
      cart
    });
  } catch (error) {
    console.error('Erreur lors du vidage du panier:', error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Appliquer un code promo
exports.applyCoupon = async (req, res) => {
  try {
    const { code } = req.body;

    if (!code) {
      return res.status(400).json({ message: 'Code promo requis' });
    }

    const cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      return res.status(404).json({ message: 'Panier non trouvé' });
    }

    // Recherche du coupon dans la base de données
    const Coupon = require('../models/Coupon');
    const coupon = await Coupon.findOne({ code: code.toUpperCase() });

    if (!coupon) {
      return res.status(400).json({ message: 'Code promo invalide' });
    }

    // Vérification de la validité du coupon
    const totalPanier = cart.totalPrix || 0;
    const validationResult = coupon.isValid(totalPanier);
    if (!validationResult.valid) {
      return res.status(400).json({ message: validationResult.message });
    }

    // Application du coupon au panier
    try {
      await cart.appliquerCodePromo(code, validationResult.discount);
      
      // Incrémenter le compteur d'utilisation
      await coupon.use();
  
      res.json(cart);
    } catch (error) {
      res.status(400).json({ message: error.message });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Exporter le middleware de rate limiting
exports.cartLimiter = cartLimiter; 