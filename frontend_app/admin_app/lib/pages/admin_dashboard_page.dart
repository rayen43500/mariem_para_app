import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import 'dart:math';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _dashboardService = DashboardService();
  final _logger = Logger();
  
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isLoadingStats = true;
  Map<String, dynamic> _dashboardStats = {
    'produits': 0,
    'categories': 0,
    'commandes': 0,
    'utilisateurs': 0,
    'promotions': 0,
  };
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  late List<CardItem> _cardItems;

  @override
  void initState() {
    super.initState();
    _initCardItems();
    _checkAuth();
    _testAuthentication();
    _loadDashboardStats();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    
    _animationController.forward();
  }
  
  void _initCardItems() {
    _cardItems = [
      CardItem(
        title: 'Produits',
        icon: Icons.medication_outlined,
        color: const Color(0xFF00A86B),
        secondaryColor: const Color(0xFF7FDCAD),
        route: '/products',
        count: '...',
        description: 'Gérez votre inventaire',
      ),
      CardItem(
        title: 'Commandes',
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFF4073FF),
        secondaryColor: const Color(0xFF85AEFF),
        route: '/orders',
        count: '...',
        description: 'Suivi des prescriptions',
      ),
      CardItem(
        title: 'Utilisateurs',
        icon: Icons.people_outline,
        color: const Color(0xFF9C27B0),
        secondaryColor: const Color(0xFFE1BEE7),
        route: '/users',
        count: '...',
        description: 'Gestion des clients',
      ),
      CardItem(
        title: 'Analyses',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF6554C0),
        secondaryColor: const Color(0xFFB8ACF6),
        route: '/stats',
        count: '',
        description: 'Statistiques de vente',
      ),
      CardItem(
        title: 'Livraisons',
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFF00B8D9),
        secondaryColor: const Color(0xFF8FDFF6),
        route: '/delivery',
        count: '...',
        description: 'Gestion des livraisons',
      ),
      CardItem(
        title: 'Promotions',
        icon: Icons.discount_outlined,
        color: const Color(0xFFFF8B00),
        secondaryColor: const Color(0xFFFFD580),
        route: '/promotions',
        count: '...',
        description: 'Remises & offres spéciales',
      ),
      CardItem(
        title: 'Catégories',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFFE53935),
        secondaryColor: const Color(0xFFFF8A80),
        route: '/categories',
        count: '...',
        description: 'Types de produit',
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    final user = await _authService.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }
  
  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoadingStats = true;
    });
    
    try {
      final stats = await _dashboardService.getDashboardStats();
      
      // Mettre à jour les nombres de chaque catégorie
      setState(() {
        _dashboardStats = stats;
        _updateCardItems();
        _isLoadingStats = false;
      });
      
    } catch (e) {
      _logger.e('Erreur lors du chargement des statistiques: $e');
      setState(() {
        _isLoadingStats = false;
      });
    }
  }
  
  void _updateCardItems() {
    // Mettre à jour les nombres dans les cartes
    for (int i = 0; i < _cardItems.length; i++) {
      final item = _cardItems[i];
      
      if (item.title == 'Produits') {
        item.count = _dashboardStats['produits'].toString();
      } else if (item.title == 'Catégories') {
        item.count = _dashboardStats['categories'].toString();
      } else if (item.title == 'Commandes') {
        item.count = _dashboardStats['commandes'].toString();
      } else if (item.title == 'Utilisateurs') {
        if (_dashboardStats.containsKey('utilisateurs') && _dashboardStats['utilisateurs'] != null) {
          item.count = _dashboardStats['utilisateurs'].toString();
        }
      } else if (item.title == 'Promotions') {
        item.count = _dashboardStats['promotions'].toString();
      } else if (item.title == 'Livraisons') {
        item.count = '3';
      }
      
      // Assurez-vous que le compteur n'est pas vide ou "0" pour l'affichage
      if (item.count == "" || item.count == "0") {
        item.count = "0";
      }
      
      print('Mise à jour carte ${item.title}: ${item.count}');
    }
  }

  Future<void> _testAuthentication() async {
    try {
      await _authService.testAuthenticatedRequest();
      // If we get here, the test succeeded, no need to show any message
    } catch (e) {
      _logger.e('Erreur lors du test d\'authentification: $e');
      // Only show the message when there's an actual error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre session est expirée. Veuillez vous reconnecter.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Chargement du tableau de bord...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isSmallScreen = size.width < 650;
    final isTinyScreen = size.width < 360;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme, isSmallScreen),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 24,
                    left: isTinyScreen ? 8 : (isSmallScreen ? 12 : 16),
                    right: isTinyScreen ? 8 : (isSmallScreen ? 12 : 16),
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isTinyScreen ? 4 : 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Tableau de bord',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  fontSize: isTinyScreen ? 18 : (isSmallScreen ? 20 : 24),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              children: [
                                if (_isLoadingStats)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _loadDashboardStats,
                                  tooltip: 'Actualiser les statistiques',
                                  iconSize: isTinyScreen ? 20 : 24,
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: isTinyScreen ? 36 : 40,
                                    minHeight: isTinyScreen ? 36 : 40,
                                  ),
                                ),
                                SizedBox(width: isTinyScreen ? 4 : 8),
                                _buildDateChip(theme, isSmallScreen, isTinyScreen),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isTinyScreen ? 12 : (isSmallScreen ? 16 : 24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isTinyScreen ? 4 : 8),
                        child: Text(
                          'Gestion',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontSize: isTinyScreen ? 16 : (isSmallScreen ? 18 : 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildDashboardGrid(isSmallScreen, isTinyScreen),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isSmallScreen) {
    final isTinyScreen = MediaQuery.of(context).size.width < 360;
    
    return Container(
      padding: EdgeInsets.fromLTRB(
        isTinyScreen ? 12 : 16, 
        8, 
        isTinyScreen ? 12 : 16, 
        16
      ),
      color: const Color(0xFF00A86B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
            child: Row(
              children: [
                Icon(
                  Icons.local_pharmacy,
                  color: Colors.white,
                  size: isTinyScreen ? 20 : (isSmallScreen ? 24 : 28),
                ),
                SizedBox(width: isTinyScreen ? 6 : 8),
                Text(
                  'PharmaDashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTinyScreen ? 16 : (isSmallScreen ? 18 : 22),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: isTinyScreen ? 18 : (isSmallScreen ? 20 : 24),
                backgroundColor: Colors.white.withOpacity(0.2),
                child: _user != null
                    ? Text(
                        _getInitials(_user!['nom'] ?? 'Pharma'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTinyScreen ? 12 : (isSmallScreen ? 14 : 16),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.white,
                        size: isTinyScreen ? 16 : 20,
                      ),
              ),
              SizedBox(width: isTinyScreen ? 8 : 12),
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                color: Colors.white,
                tooltip: 'Déconnexion',
                iconSize: isTinyScreen ? 20 : (isSmallScreen ? 22 : 24),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(
                  minWidth: isTinyScreen ? 36 : 40,
                  minHeight: isTinyScreen ? 36 : 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(ThemeData theme, bool isSmallScreen, bool isTinyScreen) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTinyScreen ? 8 : (isSmallScreen ? 12 : 16),
        vertical: isTinyScreen ? 4 : (isSmallScreen ? 6 : 8),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: isTinyScreen ? 12 : (isSmallScreen ? 14 : 16),
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: isTinyScreen ? 4 : (isSmallScreen ? 6 : 8)),
          Text(
            '${now.day} ${months[now.month - 1]} ${now.year}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontSize: isTinyScreen ? 10 : (isSmallScreen ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(bool isSmallScreen, bool isTinyScreen) {
    // Ajuster le nombre de colonnes en fonction de la taille d'écran
    int crossAxisCount = 2;
    if (MediaQuery.of(context).size.width > 900) {
      crossAxisCount = 3;
    } else if (isTinyScreen) {
      crossAxisCount = 1;
    }
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isTinyScreen ? 1.1 : (isSmallScreen ? 0.9 : 1),
            crossAxisSpacing: isTinyScreen ? 8 : (isSmallScreen ? 12 : 16),
            mainAxisSpacing: isTinyScreen ? 8 : (isSmallScreen ? 12 : 16),
          ),
          itemCount: _cardItems.length,
          itemBuilder: (context, index) {
            final delay = 0.2 + (index * 0.1);
            final delayedAnimation = min(max(_animation.value - delay, 0) / (1 - delay), 1.0);
            
            return _buildAnimatedDashboardCard(
              _cardItems[index],
              delayedAnimation,
              index,
              isSmallScreen,
              isTinyScreen,
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedDashboardCard(CardItem item, double delayedAnimation, int index, bool isSmallScreen, bool isTinyScreen) {
    final scale = 0.5 + (0.5 * Curves.elasticOut.transform(delayedAnimation));
    final opacity = Curves.easeOut.transform(delayedAnimation);
    
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: _buildDashboardCard(item, index, isSmallScreen, isTinyScreen),
      ),
    );
  }

  Widget _buildDashboardCard(CardItem item, int index, bool isSmallScreen, bool isTinyScreen) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isTinyScreen ? 14 : (isSmallScreen ? 16 : 20)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTinyScreen ? 14 : (isSmallScreen ? 16 : 20)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              item.color,
              item.secondaryColor,
            ],
            stops: const [0.2, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.3),
              blurRadius: isTinyScreen ? 6 : (isSmallScreen ? 8 : 12),
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(isTinyScreen ? 14 : (isSmallScreen ? 16 : 20)),
          child: InkWell(
            borderRadius: BorderRadius.circular(isTinyScreen ? 14 : (isSmallScreen ? 16 : 20)),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            onTap: () {
              _logger.i('Navigation vers ${item.route}');
              Navigator.pushNamed(context, item.route);
            },
            child: Padding(
              padding: EdgeInsets.all(isTinyScreen ? 12 : (isSmallScreen ? 16 : 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(isTinyScreen ? 6 : (isSmallScreen ? 8 : 10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isTinyScreen ? 10 : (isSmallScreen ? 12 : 14)),
                    ),
                    child: Icon(
                      item.icon,
                      size: isTinyScreen ? 20 : (isSmallScreen ? 24 : 28),
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.count.isNotEmpty) ...[
                        Text(
                          item.count,
                          style: TextStyle(
                            fontSize: isTinyScreen ? 18 : (isSmallScreen ? 22 : 26),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isTinyScreen ? 1 : (isSmallScreen ? 2 : 4)),
                      ],
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: isTinyScreen ? 14 : (isSmallScreen ? 16 : 18),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isTinyScreen ? 0 : (isSmallScreen ? 1 : 2)),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: isTinyScreen ? 10 : (isSmallScreen ? 11 : 12),
                          color: Colors.white.withOpacity(0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return nameParts[0][0] + nameParts[1][0];
    } else if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    } else {
      return name.toUpperCase();
    }
  }
}

class CardItem {
  final String title;
  final IconData icon;
  final Color color;
  final Color secondaryColor;
  final String route;
  String count;
  final String description;

  CardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.secondaryColor,
    required this.route,
    required this.count,
    required this.description,
  });
} 