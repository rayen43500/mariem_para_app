class Product {
  final String id;
  final String nom;
  final String description;
  final double prix;
  final double? prixPromo;
  final double? discount;
  final List<String> images;
  final int stock;
  final String categorie;
  final bool disponible;
  final double? rating;
  final int? reviewCount;
  final bool isActive;

  Product({
    required this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.prixPromo,
    this.discount,
    required this.images,
    required this.stock,
    required this.categorie,
    required this.disponible,
    this.rating,
    this.reviewCount,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String categoryName = 'Non catégorisé';
    
    // Gérer le cas où categoryId est un objet ou une chaîne
    if (json['categoryId'] != null) {
      if (json['categoryId'] is Map) {
        categoryName = json['categoryId']['nom'] ?? 'Non catégorisé';
      } else if (json['categoryId'] is String) {
        categoryName = json['categoryId'];
      }
    }
    
    return Product(
      id: json['_id'] ?? '',
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      prix: json['prix']?.toDouble() ?? 0.0,
      prixPromo: json['prixPromo']?.toDouble(),
      discount: json['discount']?.toDouble(),
      images: json['images'] != null 
          ? List<String>.from(json['images'])
          : [],
      stock: json['stock'] ?? 0,
      categorie: categoryName,
      disponible: json['stock'] > 0 && (json['isActive'] ?? true),
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'prixPromo': prixPromo,
      'discount': discount,
      'images': images,
      'stock': stock,
      'categorie': categorie,
      'disponible': disponible,
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
    };
  }

  // Copier avec des modifications
  Product copyWith({
    String? id,
    String? nom,
    String? description,
    double? prix,
    double? prixPromo,
    double? discount,
    List<String>? images,
    int? stock,
    String? categorie,
    bool? disponible,
    double? rating,
    int? reviewCount,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      prixPromo: prixPromo ?? this.prixPromo,
      discount: discount ?? this.discount,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      categorie: categorie ?? this.categorie,
      disponible: disponible ?? this.disponible,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
    );
  }
} 