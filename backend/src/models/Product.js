const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  nom: {
    type: String,
    required: true
  },
  note: {
    type: Number,
    required: true,
    min: 1,
    max: 5
  },
  commentaire: {
    type: String,
    required: true,
    trim: true
  }
}, {
  timestamps: true
});

const productSchema = new mongoose.Schema({
  nom: {
    type: String,
    required: [true, 'Le nom du produit est requis'],
    trim: true
  },
  description: {
    type: String,
    required: [true, 'La description est requise'],
    trim: true
  },
  prix: {
    type: Number,
    required: [true, 'Le prix est requis'],
    min: [0, 'Le prix ne peut pas être négatif']
  },
  prixPromo: {
    type: Number,
    min: [0, 'Le prix promo ne peut pas être négatif']
  },
  discount: {
    type: Number,
    min: [0, 'La réduction ne peut pas être négative'],
    max: [100, 'La réduction ne peut pas dépasser 100%']
  },
  images: [{
    type: String,
    required: [true, 'Au moins une image est requise']
  }],
  stock: {
    type: Number,
    required: [true, 'Le stock est requis'],
    min: [0, 'Le stock ne peut pas être négatif']
  },
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: [true, 'La catégorie est requise']
  },
  isActive: {
    type: Boolean,
    default: true
  },
  ratings: {
    type: Number,
    default: 0
  },
  reviews: [reviewSchema]
}, {
  timestamps: true
});

// Middleware pour calculer la moyenne des notes
productSchema.methods.calculateAverageRating = function() {
  if (this.reviews.length === 0) {
    this.ratings = 0;
    return;
  }

  const sum = this.reviews.reduce((acc, review) => acc + review.note, 0);
  this.ratings = sum / this.reviews.length;
};

// Middleware pour mettre à jour la moyenne des notes après chaque avis
productSchema.pre('save', function(next) {
  this.calculateAverageRating();
  next();
});

// Méthode pour ajouter un avis
productSchema.methods.addReview = async function(userId, nom, note, commentaire) {
  const review = {
    userId,
    nom,
    note,
    commentaire
  };

  this.reviews.push(review);
  this.calculateAverageRating();
  await this.save();
  return this;
};

module.exports = mongoose.model('Product', productSchema); 