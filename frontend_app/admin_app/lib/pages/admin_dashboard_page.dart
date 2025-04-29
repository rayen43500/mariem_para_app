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
      
      if (item.title == 'Médicaments') {
        item.count = _dashboardStats['produits'].toString();
      } else if (item.title == 'Catégories') {
        item.count = _dashboardStats['categories'].toString();
      } else if (item.title == 'Ordonnances') {
        item.count = _dashboardStats['commandes'].toString();
      } else if (item.title == 'Patients') {
        if (_dashboardStats.containsKey('utilisateurs') && _dashboardStats['utilisateurs'] != null) {
          item.count = _dashboardStats['utilisateurs'].toString();
        }
      } else if (item.title == 'Promotions') {
        item.count = _dashboardStats['promotions'].toString();
      } else if (item.title == 'Livraisons') {
        item.count = '3';
      }
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
    final isSmallScreen = size.width < 600;

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
                    left: isSmallScreen ? 12 : 16,
                    right: isSmallScreen ? 12 : 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tableau de bord',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                                fontSize: isSmallScreen ? 20 : 24,
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
                                ),
                                const SizedBox(width: 8),
                                _buildDateChip(theme, isSmallScreen),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      _buildSummaryCards(theme, isSmallScreen),
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Gestion',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontSize: isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildDashboardGrid(isSmallScreen),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                  size: isSmallScreen ? 24 : 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'PharmaDashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 18 : 22,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: isSmallScreen ? 20 : 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: _user != null
                    ? Text(
                        _getInitials(_user!['nom'] ?? 'Pharma'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                color: Colors.white,
                tooltip: 'Déconnexion',
                iconSize: isSmallScreen ? 22 : 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(ThemeData theme, bool isSmallScreen) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
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
            size: isSmallScreen ? 14 : 16,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Text(
            '${now.day} ${months[now.month - 1]} ${now.year}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme, bool isSmallScreen) {
    return SizedBox(
      height: isSmallScreen ? 100 : 110,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSummaryCard(
                icon: Icons.euro_symbol_outlined,
                title: 'Ventes du jour',
                value: '€ 1,256.50',
                change: '+12.5%',
                isPositive: true,
                color: const Color(0xFF00A86B),
                animationValue: _animation.value,
                delay: 0,
                isSmallScreen: isSmallScreen,
              ),
              _buildSummaryCard(
                icon: Icons.receipt_long_outlined,
                title: 'Ordonnances',
                value: '26',
                change: '+8.2%',
                isPositive: true,
                color: const Color(0xFF4073FF),
                animationValue: _animation.value,
                delay: 0.1,
                isSmallScreen: isSmallScreen,
              ),
              _buildSummaryCard(
                icon: Icons.person_add_outlined,
                title: 'Nouveaux patients',
                value: '12',
                change: '-2.4%',
                isPositive: false,
                color: const Color(0xFF9C27B0),
                animationValue: _animation.value,
                delay: 0.2,
                isSmallScreen: isSmallScreen,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color color,
    required double animationValue,
    required double delay,
    required bool isSmallScreen,
  }) {
    final delayedAnimation = min(max(animationValue - delay, 0) / (1 - delay), 1.0);
    final offset = 1 - Curves.easeOutCubic.transform(delayedAnimation);
    
    return Transform.translate(
      offset: Offset(50 * offset, 0),
      child: Opacity(
        opacity: delayedAnimation,
        child: Container(
          margin: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          width: isSmallScreen ? 170 : 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: isSmallScreen ? 16 : 20,
                      color: color,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: isSmallScreen ? 3 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: isSmallScreen ? 10 : 12,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: isSmallScreen ? 1 : 2),
                        Text(
                          change,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 9 : 10,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 12,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: isSmallScreen ? 0.85 : 1,
            crossAxisSpacing: isSmallScreen ? 12 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
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
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedDashboardCard(CardItem item, double delayedAnimation, int index, bool isSmallScreen) {
    final scale = 0.5 + (0.5 * Curves.elasticOut.transform(delayedAnimation));
    final opacity = Curves.easeOut.transform(delayedAnimation);
    
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: _buildDashboardCard(item, index, isSmallScreen),
      ),
    );
  }

  Widget _buildDashboardCard(CardItem item, int index, bool isSmallScreen) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
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
              blurRadius: isSmallScreen ? 8 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          child: InkWell(
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.white.withOpacity(0.1),
            onTap: () {
              _logger.i('Navigation vers ${item.route}');
              Navigator.pushNamed(context, item.route);
            },
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                    ),
                    child: Icon(
                      item.icon,
                      size: isSmallScreen ? 24 : 28,
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
                            fontSize: isSmallScreen ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 2 : 4),
                      ],
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 1 : 2),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
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