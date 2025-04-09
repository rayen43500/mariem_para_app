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
    const { produitId, quantité } = req.body;

    // Vérifier si le produit existe et est en stock
    const produit = await Product.findById(produitId);
    if (!produit || !produit.isActive) {
      return res.status(404).json({ message: 'Produit non trouvé ou non disponible' });
    }

    if (produit.stock < quantité) {
      return res.status(400).json({ message: 'Stock insuffisant' });
    }

    // Trouver ou créer le panier
    let cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      cart = new Cart({ userId: req.user.id });
    }

    // Ajouter le produit au panier
    await cart.ajouterProduit(produitId, quantité, produit.prix);

    res.status(201).json(cart);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Mettre à jour la quantité d'un produit
exports.updateCartItem = async (req, res) => {
  try {
    const { quantité } = req.body;
    const { produitId } = req.params;

    // Vérifier si le produit existe et est en stock
    const produit = await Product.findById(produitId);
    if (!produit || !produit.isActive) {
      return res.status(404).json({ message: 'Produit non trouvé ou non disponible' });
    }

    if (produit.stock < quantité) {
      return res.status(400).json({ message: 'Stock insuffisant' });
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

    res.json(cart);
  } catch (error) {
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
    res.json(cart);
  } catch (error) {
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
    res.json({ message: 'Panier vidé avec succès' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Appliquer un code promo
exports.applyCoupon = async (req, res) => {
  try {
    const { code } = req.body;

    // Ici, vous devriez vérifier le code promo dans votre base de données
    // Pour l'exemple, nous utilisons un code fixe
    const validCoupons = {
      'WELCOME10': 10,
      'SALE20': 20
    };

    if (!validCoupons[code]) {
      return res.status(400).json({ message: 'Code promo invalide' });
    }

    const cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      return res.status(404).json({ message: 'Panier non trouvé' });
    }

    await cart.appliquerCodePromo(code, validCoupons[code]);
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Exporter le middleware de rate limiting
exports.cartLimiter = cartLimiter; 