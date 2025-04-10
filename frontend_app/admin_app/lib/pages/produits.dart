import 'package:flutter/material.dart';
import 'dart:io';
import 'package:logger/logger.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/image_service.dart';
import '../models/product_model.dart';
import 'dart:async';

class ProduitsPage extends StatefulWidget {
  const ProduitsPage({super.key});

  @override
  State<ProduitsPage> createState() => _ProduitsPageState();
}

class _ProduitsPageState extends State<ProduitsPage> {
  final _authService = AuthService();
  final _productService = ProductService();
  final _imageService = ImageService();
  final _logger = Logger();
  
  bool _isLoading = true;
  List<Product> _produits = [];
  Map<String, dynamic>? _pagination;
  
  // Filtres et tri
  String _searchQuery = '';
  String _selectedCategorie = 'Toutes';
  final List<String> _categories = ['Toutes', 'Électronique', 'Accessoires', 'Informatique', 'Wearables', 'Audio'];

  // Pour la gestion des images
  File? _selectedImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _productService.getProducts(
        category: _selectedCategorie == 'Toutes' ? null : _selectedCategorie,
        limit: 20,
      );
      
      List<Product> products = (response['products'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
      
      setState(() {
        _produits = products;
        _pagination = {
          'total': response['total'],
          'page': response['page'],
          'pages': response['pages'],
        };
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Erreur lors du chargement des produits: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  Future<void> _deleteProduct(String id) async {
    try {
      // Ici, appeler l'API pour supprimer le produit
      // Pour l'instant, on simule la suppression localement
      setState(() {
        _produits.removeWhere((product) => product.id == id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit supprimé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  // Méthode pour choisir une image
  Future<void> _pickImage() async {
    try {
      final File? image = await _imageService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection de l\'image: $e')),
        );
      }
    }
  }

  // Méthode pour télécharger l'image
  Future<String?> _uploadSelectedImage() async {
    if (_selectedImage == null) return null;
    
    setState(() {
      _isUploadingImage = true;
    });
    
    try {
      final imageUrl = await _imageService.uploadImage(_selectedImage!);
      setState(() {
        _uploadedImageUrl = imageUrl;
        _isUploadingImage = false;
      });
      return imageUrl;
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement de l\'image: $e')),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProduits = _produits.where((product) {
      final matchesSearch = product.nom.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategorie == 'Toutes' || product.categorie == _selectedCategorie;
      return matchesSearch && matchesCategory;
    }).toList();

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des produits'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddEditProductDialog(context);
            },
            tooltip: 'Ajouter un produit',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategorie;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategorie = category;
                              });
                              // Charger les produits avec le nouveau filtre
                              _loadProducts();
                            }
                          },
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProduits.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun produit trouvé',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProduits.length,
                          itemBuilder: (context, index) {
                            final product = filteredProduits[index];
                            return _buildProductCard(product, theme, isSmallScreen);
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditProductDialog(context);
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductCard(Product product, ThemeData theme, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images.isNotEmpty ? product.images[0] : 'https://picsum.photos/200/300',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.disponible
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.disponible ? 'En stock' : 'Épuisé',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                product.disponible ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '€${product.prix.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.categorie,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () {
                          _showAddEditProductDialog(context, product: product);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () {
                          _confirmDeleteProduct(context, product);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditProductDialog(BuildContext context, {Product? product}) {
    final theme = Theme.of(context);
    final isEditing = product != null;
    
    // Réinitialiser les variables d'image
    _selectedImage = null;
    _uploadedImageUrl = null;
    
    // Si on édite, on initialise avec les valeurs existantes
    final TextEditingController nameController = TextEditingController(text: isEditing ? product.nom : '');
    final TextEditingController priceController = TextEditingController(text: isEditing ? product.prix.toString() : '');
    final TextEditingController stockController = TextEditingController(text: isEditing ? product.stock.toString() : '');
    final TextEditingController imageController = TextEditingController(text: isEditing && product.images.isNotEmpty ? product.images[0] : '');
    final TextEditingController descriptionController = TextEditingController(text: isEditing ? product.description : '');
    
    String selectedCategory = isEditing ? product.categorie : _categories[1];
    bool isAvailable = isEditing ? product.disponible : true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Modifier le produit' : 'Ajouter un produit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du produit',
                        hintText: 'Ex: Smartphone XYZ Pro',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Prix (€)',
                        hintText: 'Ex: 599.99',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        labelText: 'Quantité en stock',
                        hintText: 'Ex: 45',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Ex: Un smartphone de dernière génération...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Image du produit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: imageController,
                            decoration: const InputDecoration(
                              labelText: 'URL de l\'image',
                              hintText: 'Ex: https://example.com/image.jpg',
                            ),
                            enabled: _selectedImage == null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.photo_library),
                          onPressed: () async {
                            await _pickImage();
                            if (_selectedImage != null) {
                              setState(() {
                                // Mise à jour de l'interface avec l'image sélectionnée
                              });
                            }
                          },
                          tooltip: 'Sélectionner depuis la galerie',
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_selectedImage != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.file(
                                  _selectedImage!,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                                if (_isUploadingImage)
                                  Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Changer'),
                                onPressed: () async {
                                  await _pickImage();
                                  setState(() {
                                    // Mise à jour après nouvelle sélection
                                  });
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete),
                                label: const Text('Supprimer'),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _uploadedImageUrl = null;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                      ),
                      items: _categories
                          .where((category) => category != 'Toutes')
                          .map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedCategory = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Disponible à la vente'),
                      value: isAvailable,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            isAvailable = value;
                          });
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Télécharger l'image si présente
                      String? imageUrl;
                      if (_selectedImage != null) {
                        imageUrl = await _uploadSelectedImage();
                        if (imageUrl == null) return; // Échec du téléchargement
                      }
                      
                      final double price = double.tryParse(priceController.text) ?? 0.0;
                      final int stock = int.tryParse(stockController.text) ?? 0;
                      
                      final Map<String, dynamic> productData = {
                        'nom': nameController.text,
                        'prix': price,
                        'description': descriptionController.text,
                        'stock': stock,
                        'categorie': selectedCategory,
                        'images': imageUrl != null ? [imageUrl] : 
                                  imageController.text.isNotEmpty ? [imageController.text] : ['https://picsum.photos/200/300'],
                        'isActive': isAvailable,
                      };
                      
                      if (isEditing) {
                        // Mettre à jour le produit
                        await _productService.updateProduct(product.id, productData);
                      } else {
                        // Créer un nouveau produit
                        await _productService.createProduct(productData);
                      }
                      
                      // Recharger les produits
                      _loadProducts();
                      
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? 'Produit mis à jour avec succès'
                                  : 'Produit ajouté avec succès',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le produit'),
          content: Text('Êtes-vous sûr de vouloir supprimer "${product.nom}" ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProduct(product.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
