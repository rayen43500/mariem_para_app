const Product = require('../models/Product');
const Category = require('../models/Category');

// Créer un produit
exports.createProduct = async (req, res) => {
  try {
    const {
      nom,
      description,
      prix,
      prixPromo,
      discount,
      images,
      stock,
      categoryId
    } = req.body;

    // Vérifier si la catégorie existe
    const category = await Category.findById(categoryId);
    if (!category) {
      return res.status(404).json({ message: 'Catégorie non trouvée' });
    }

    const product = new Product({
      nom,
      description,
      prix,
      prixPromo,
      discount,
      images,
      stock,
      categoryId
    });

    await product.save();

    res.status(201).json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Mettre à jour un produit
exports.updateProduct = async (req, res) => {
  try {
    const {
      nom,
      description,
      prix,
      prixPromo,
      discount,
      images,
      stock,
      categoryId,
      isActive
    } = req.body;

    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    // Vérifier si la catégorie existe
    if (categoryId) {
      const category = await Category.findById(categoryId);
      if (!category) {
        return res.status(404).json({ message: 'Catégorie non trouvée' });
      }
    }

    product.nom = nom || product.nom;
    product.description = description || product.description;
    product.prix = prix || product.prix;
    product.prixPromo = prixPromo !== undefined ? prixPromo : product.prixPromo;
    product.discount = discount !== undefined ? discount : product.discount;
    product.images = images || product.images;
    product.stock = stock !== undefined ? stock : product.stock;
    product.categoryId = categoryId || product.categoryId;
    product.isActive = isActive !== undefined ? isActive : product.isActive;

    await product.save();

    res.json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Obtenir tous les produits avec filtres
exports.getProducts = async (req, res) => {
  try {
    const {
      category,
      minPrice,
      maxPrice,
      inStock,
      onSale,
      sortBy,
      limit = 10,
      page = 1
    } = req.query;

    let query = { isActive: true };

    // Filtres
    if (category) {
      query.categoryId = category;
    }
    if (minPrice) {
      query.prix = { ...query.prix, $gte: Number(minPrice) };
    }
    if (maxPrice) {
      query.prix = { ...query.prix, $lte: Number(maxPrice) };
    }
    if (inStock === 'true') {
      query.stock = { $gt: 0 };
    }
    if (onSale === 'true') {
      query.discount = { $gt: 0 };
    }

    // Tri
    let sortOptions = {};
    switch (sortBy) {
      case 'price-asc':
        sortOptions = { prix: 1 };
        break;
      case 'price-desc':
        sortOptions = { prix: -1 };
        break;
      case 'rating':
        sortOptions = { ratings: -1 };
        break;
      case 'newest':
        sortOptions = { createdAt: -1 };
        break;
      default:
        sortOptions = { createdAt: -1 };
    }

    const skip = (page - 1) * limit;

    const products = await Product.find(query)
      .populate('categoryId', 'nom slug')
      .sort(sortOptions)
      .skip(skip)
      .limit(Number(limit));

    const total = await Product.countDocuments(query);

    res.json({
      products,
      total,
      page: Number(page),
      pages: Math.ceil(total / limit)
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Obtenir un produit par son ID
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate('categoryId', 'nom slug')
      .populate('reviews.userId', 'nom');

    if (!product) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    res.json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Ajouter un avis à un produit
exports.addReview = async (req, res) => {
  try {
    const { note, commentaire } = req.body;
    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    // Vérifier si l'utilisateur a déjà laissé un avis
    const existingReview = product.reviews.find(
      review => review.userId.toString() === req.user.id
    );

    if (existingReview) {
      return res.status(400).json({ message: 'Vous avez déjà laissé un avis sur ce produit' });
    }

    await product.addReview(
      req.user.id,
      req.user.nom,
      note,
      commentaire
    );

    res.json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Rechercher des produits
exports.searchProducts = async (req, res) => {
  try {
    const { q } = req.query;
    const limit = Number(req.query.limit) || 10;

    if (!q) {
      return res.status(400).json({ message: 'Le terme de recherche est requis' });
    }

    const products = await Product.find({
      $and: [
        { isActive: true },
        {
          $or: [
            { nom: { $regex: q, $options: 'i' } },
            { description: { $regex: q, $options: 'i' } }
          ]
        }
      ]
    })
      .populate('categoryId', 'nom slug')
      .limit(limit);

    res.json(products);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
}; 