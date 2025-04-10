class Product {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final double? prixFinal; // Prix après réduction
  final List<String> images;
  final int stock;
  final String categorie;
  final String categoryId;
  final bool disponible;
  final double? ratings;
  final Map<String, dynamic>? reduction;

  Product({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.prixFinal,
    required this.images,
    required this.stock,
    required this.categorie,
    required this.categoryId,
    required this.disponible,
    this.ratings,
    this.reduction,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Obtenir le nom de la catégorie
    String categorieName = '';
    if (json['categoryId'] != null && json['categoryId']['nom'] != null) {
      categorieName = json['categoryId']['nom'];
    } else if (json['categoryId'] is String) {
      // Mapper les IDs aux noms
      final categoryMapping = {
        'CAT1': 'Électronique',
        'CAT2': 'Accessoires',
        'CAT3': 'Informatique',
        'CAT4': 'Wearables',
        'CAT5': 'Audio',
      };
      categorieName = categoryMapping[json['categoryId']] ?? 'Autre';
    }

    return Product(
      id: json['_id'] ?? '',
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      prix: (json['prix'] ?? 0).toDouble(),
      prixFinal: json['prixFinal'] != null ? json['prixFinal'].toDouble() : null,
      images: List<String>.from(json['images'] ?? []),
      stock: json['stock'] ?? 0,
      categorie: categorieName,
      categoryId: json['categoryId'] is Map ? json['categoryId']['_id'] : json['categoryId'] ?? '',
      disponible: json['stock'] > 0 && (json['isActive'] ?? true),
      ratings: json['ratings']?.toDouble() ?? 0.0,
      reduction: json['reduction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'prixFinal': prixFinal,
      'images': images,
      'stock': stock,
      'categoryId': categoryId,
      'isActive': disponible,
      'ratings': ratings,
    };
  }

  // Copier avec des modifications
  Product copyWith({
    String? id,
    String? nom,
    String? description,
    double? prix,
    double? prixFinal,
    List<String>? images,
    int? stock,
    String? categorie,
    String? categoryId,
    bool? disponible,
    double? ratings,
    Map<String, dynamic>? reduction,
  }) {
    return Product(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      prixFinal: prixFinal ?? this.prixFinal,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      categorie: categorie ?? this.categorie,
      categoryId: categoryId ?? this.categoryId,
      disponible: disponible ?? this.disponible,
      ratings: ratings ?? this.ratings,
      reduction: reduction ?? this.reduction,
    );
  }
} 