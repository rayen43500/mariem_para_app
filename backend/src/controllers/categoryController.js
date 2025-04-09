const Category = require('../models/Category');

// Créer une catégorie
exports.createCategory = async (req, res) => {
  try {
    const { nom, description, parentCategory } = req.body;

    const category = new Category({
      nom,
      description,
      parentCategory: parentCategory || null
    });

    await category.save();

    res.status(201).json(category);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Mettre à jour une catégorie
exports.updateCategory = async (req, res) => {
  try {
    const { nom, description, parentCategory } = req.body;
    const category = await Category.findById(req.params.id);

    if (!category) {
      return res.status(404).json({ message: 'Catégorie non trouvée' });
    }

    category.nom = nom || category.nom;
    category.description = description || category.description;
    category.parentCategory = parentCategory || category.parentCategory;

    await category.save();

    res.json(category);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Supprimer une catégorie
exports.deleteCategory = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);

    if (!category) {
      return res.status(404).json({ message: 'Catégorie non trouvée' });
    }

    // Vérifier si la catégorie a des sous-catégories
    const hasSubCategories = await Category.exists({ parentCategory: category._id });
    if (hasSubCategories) {
      return res.status(400).json({ message: 'Impossible de supprimer une catégorie qui a des sous-catégories' });
    }

    await category.remove();

    res.json({ message: 'Catégorie supprimée avec succès' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Obtenir toutes les catégories
exports.getCategories = async (req, res) => {
  try {
    const categories = await Category.find()
      .populate('parentCategory', 'nom slug')
      .sort({ nom: 1 });

    res.json(categories);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Obtenir une catégorie par son ID
exports.getCategoryById = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id)
      .populate('parentCategory', 'nom slug');

    if (!category) {
      return res.status(404).json({ message: 'Catégorie non trouvée' });
    }

    res.json(category);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Erreur serveur' });
  }
}; 