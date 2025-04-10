import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../services/promotion_service.dart';
import '../services/cart_service.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();
  final PromotionService _promotionService = PromotionService();
  
  List<dynamic> _categories = [];
  List<dynamic> _products = [];
  List<dynamic> _promotions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      print('⭐ Début du chargement des données...');
      
      // Récupération des catégories
      final categories = await _categoryService.getCategories();
      print('📂 ${categories.length} catégories récupérées');
      bool categoriesFromTest = categories.any((cat) => cat['_id'].toString().startsWith('cat'));
      
      // Récupération des produits
      final products = await _productService.getProducts(limit: 20);
      print('📦 ${products.length} produits récupérés');
      bool productsFromTest = products.any((prod) => prod['_id'].toString().startsWith('test'));

      // Récupération des promotions
      final promotions = await _promotionService.getPromotions();
      print('🏷️ ${promotions.length} promotions récupérées');
      
      // Mise à jour de l'interface
      setState(() {
        _categories = categories;
        _products = products;
        _promotions = promotions;
        _isLoading = false;
        
        // Afficher un message selon l'origine des données
        if (categoriesFromTest || productsFromTest) {
          _showDataSourceMessage(categoriesFromTest, productsFromTest);
        }
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  // Afficher un message à l'utilisateur concernant la source des données
  void _showDataSourceMessage(bool categoriesFromTest, bool productsFromTest) {
    if (!mounted) return;
    
    String message = '';
    if (categoriesFromTest && productsFromTest) {
      message = 'Affichage de données de test (API non connectée)';
    } else if (categoriesFromTest) {
      message = 'Catégories: données de test, Produits: API';
    } else if (productsFromTest) {
      message = 'Produits: données de test, Catégories: API';
    }
    
    if (message.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      });
    }
  }

  // Nouvelle fonction pour charger plus de produits par catégorie
  Future<void> _loadProductsByCategory(String categoryId) async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.getProducts(category: categoryId, limit: 20);
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _searchProducts() async {
    if (_searchQuery.isEmpty) {
      await _loadData();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await _productService.searchProducts(_searchQuery);
      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parapharmacie'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implémenter les notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                user?['nom'] ?? 'Utilisateur',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(user?['email'] ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  (user?['nom'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Catégories'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Promotions'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Mes commandes'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon profil'),
              selected: _selectedIndex == 4,
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              selected: _selectedIndex == 5,
              onTap: () {
                setState(() {
                  _selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                await context.read<AuthProvider>().logout();
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.lightTextColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Promotions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildCategoriesTab();
      case 2:
        return _buildPromotionsTab();
      case 3:
        return _buildCartTab();
      case 4:
        return _buildProfileTab();
      case 5:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryColor,
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bannière promotionnelle en haut
                if (_promotions.isNotEmpty)
                  _buildPromotionBanner(),
                
                // Barre de recherche et bouton de rafraîchissement
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      // Barre de recherche
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppTheme.primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Rechercher un produit...',
                                    hintStyle: TextStyle(color: AppTheme.lightTextColor),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                    _searchProducts();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bouton de rafraîchissement
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        color: AppTheme.primaryColor,
                        onPressed: () {
                          _loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Actualisation des données...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Indicateur de source de données (API ou Test)
                if (_isUsingTestData())
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Données de test affichées. API non connectée.',
                            style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Catégories sous forme de grille
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Explorer par catégorie',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoriesGrid(),
                    ],
                  ),
                ),
                
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Container(
                    height: 1,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                
                // Produits en vedette avec titre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Produits populaires',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Les meilleurs produits sélectionnés pour vous',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeaturedProductsGrid(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Indicateur de chargement
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // Vérifier si nous utilisons des données de test
  bool _isUsingTestData() {
    if (_categories.isEmpty || _products.isEmpty) return false;
    
    bool hasTestCategories = _categories.any((cat) => cat['_id'].toString().startsWith('cat'));
    bool hasTestProducts = _products.any((prod) => prod['_id'].toString().startsWith('test'));
    
    return hasTestCategories || hasTestProducts;
  }

  // Widget pour la grille de catégories
  Widget _buildCategoriesGrid() {
    if (_categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Aucune catégorie disponible')),
      );
    }

    // Utiliser seulement les premières catégories (jusqu'à 6)
    final displayCategories = _categories.length > 6 
        ? _categories.sublist(0, 6) 
        : _categories;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: displayCategories.length,
      itemBuilder: (context, index) {
        final category = displayCategories[index];
        return _buildCategoryGridItem(category);
      },
    );
  }

  // Widget pour chaque élément de catégorie de la grille
  Widget _buildCategoryGridItem(dynamic category) {
    final String icon = category['iconName'] ?? 'category';
    final String name = category['nom'] ?? 'Catégorie';
    final String color = category['colorName'] ?? 'blue';
    
    return InkWell(
      onTap: () {
        if (category['_id'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(
                categoryId: category['_id'],
                categoryName: name,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: _getCategoryColor(color).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(icon),
              color: _getCategoryColor(color),
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Widget pour la grille des produits en vedette
  Widget _buildFeaturedProductsGrid() {
    if (_products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text('Aucun produit disponible'),
        ),
      );
    }

    // Limiter à 6 produits maximum
    final displayProducts = _products.length > 6 
        ? _products.sublist(0, 6) 
        : _products;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: displayProducts.length,
      itemBuilder: (context, index) {
        final product = displayProducts[index];
        return _buildProductGridItem(product);
      },
    );
  }

  // Widget amélioré pour chaque produit dans la grille
  Widget _buildProductGridItem(dynamic product) {
    // Données du produit avec valeurs par défaut
    final String name = product['nom'] ?? 'Produit sans nom';
    final double price = (product['prix'] is num) ? product['prix'].toDouble() : 0.0;
    final double discountPrice = (product['prixFinal'] is num) ? product['prixFinal'].toDouble() : price;
    final List<dynamic> images = product['images'] is List ? product['images'] : [];
    final String imageUrl = images.isNotEmpty ? images[0] : 'https://via.placeholder.com/150';
    final bool hasDiscount = discountPrice < price;
    final int stock = product['stock'] is num ? product['stock'] : 0;
    
    return GestureDetector(
      onTap: () {
        if (product['_id'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product['_id']),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // Badge promotion ou rupture
                  if (hasDiscount || stock == 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: stock == 0 
                              ? Colors.grey[800] 
                              : AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stock == 0 
                              ? 'Rupture' 
                              : '-${(((price - discountPrice) / price) * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Informations produit
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom du produit
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Prix
                  Row(
                    children: [
                      Text(
                        '$discountPrice DH',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: hasDiscount ? AppTheme.primaryColor : Colors.black,
                        ),
                      ),
                      if (hasDiscount)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '$price DH',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  // Bouton d'ajout au panier
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: stock > 0 ? () {
                        // Logique d'ajout au panier
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$name ajouté au panier')),
                        );
                      } : null,
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('Ajouter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour la bannière promotionnelle
  Widget _buildPromotionBanner() {
    if (_promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    final promotion = _promotions[0];
    final hasImage = promotion['image'] != null && promotion['image'].toString().isNotEmpty;
    
    return Container(
      height: 160,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond (si disponible)
          if (hasImage)
            Opacity(
              opacity: 0.4,
              child: Image.network(
                promotion['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(),
              ),
            ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre de la promotion
                Text(
                  promotion['nom'] ?? 'Offre spéciale',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Description (si disponible)
                if (promotion['description'] != null)
                  Text(
                    promotion['description'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                
                const SizedBox(height: 16),
                
                // Bouton d'action
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2; // Aller à l'onglet promotions
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Voir les offres'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Column(
      children: [
        // Titre et description
        Container(
          padding: const EdgeInsets.all(16.0),
          color: AppTheme.secondaryColor.withOpacity(0.3),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toutes nos catégories',
                style: AppTheme.headingTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Parcourez nos différentes catégories de produits',
                style: AppTheme.smallTextStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        
        // Grille de catégories
        Expanded(
          child: _categories.isEmpty 
              ? const Center(child: Text('Aucune catégorie disponible'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(dynamic category) {
    final String name = category['nom'] ?? 'Catégorie';
    final String icon = category['iconName'] ?? 'category';
    final String color = category['colorName'] ?? 'blue';
    final int productCount = category['productCount'] ?? 0;

    return InkWell(
      onTap: () {
        if (category['_id'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(
                categoryId: category['_id'],
                categoryName: name,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getCategoryColor(color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(icon),
                size: 36,
                color: _getCategoryColor(color),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: AppTheme.subtitleTextStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              productCount == 1 
                  ? '1 produit' 
                  : '$productCount produits',
              style: AppTheme.smallTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionsTab() {
    if (_promotions.isEmpty) {
      return const Center(
        child: Text('Aucune promotion disponible'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _promotions.length,
      itemBuilder: (context, index) {
        final promotion = _promotions[index];
        return _buildPromotionCard(promotion);
      },
    );
  }

  Widget _buildPromotionCard(dynamic promotion) {
    final String name = promotion['nom'] ?? 'Promotion';
    final String description = promotion['description'] ?? '';
    final String code = promotion['codePromo'] ?? '';
    final dynamic reduction = promotion['valeurReduction'];
    final String imageUrl = promotion['image'] ?? 'https://via.placeholder.com/600x300?text=Promotion';
    final DateTime? endDate = promotion['dateFin'] != null 
        ? DateTime.tryParse(promotion['dateFin']) 
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50, color: AppTheme.lightTextColor),
                ),
              ),
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et badge de réduction
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (reduction != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          '-$reduction%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Description
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.lightTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Date de fin
                if (endDate != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.event, size: 16, color: AppTheme.lightTextColor),
                      const SizedBox(width: 4),
                      Text(
                        'Valable jusqu\'au ${_formatDate(endDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Code promo
                if (code.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Code promo: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            code,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            // Logique pour copier le code
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Code $code copié')),
                            );
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Bouton pour appliquer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Naviguer vers les produits concernés
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoryScreen(
                            categoryId: '',
                            categoryName: 'Produits en promotion',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Voir les produits'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildOrdersTab() {
    return const Center(
      child: Text('Mes commandes - À venir'),
    );
  }

  Widget _buildCartTab() {
    return const CartScreen();
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Text('Mon profil - À venir'),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Paramètres - À venir'),
    );
  }

  Color _getCategoryColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'teal': return Colors.teal;
      default: return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'medication': return Icons.medication;
      case 'face': return Icons.face;
      case 'fitness': return Icons.fitness_center;
      case 'spa': return Icons.spa;
      case 'baby': return Icons.child_care;
      case 'hygiene': return Icons.cleaning_services;
      case 'watch': return Icons.watch;
      case 'category': return Icons.category;
      default: return Icons.local_pharmacy;
    }
  }
} 