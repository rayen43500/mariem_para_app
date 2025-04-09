import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/auth_service.dart';
import 'dart:math';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _logger = Logger();
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final List<CardItem> _cardItems = [
    CardItem(
      title: 'Produits',
      icon: Icons.shopping_bag_outlined,
      color: const Color(0xFF4A6FFF),
      secondaryColor: const Color(0xFF84A9FF),
      route: '/products',
      count: '124',
      description: 'Gérez votre catalogue',
    ),
    CardItem(
      title: 'Commandes',
      icon: Icons.shopping_cart_outlined,
      color: const Color(0xFF36B37E),
      secondaryColor: const Color(0xFF79F2C0),
      route: '/orders',
      count: '26',
      description: 'Suivi des commandes',
    ),
    CardItem(
      title: 'Utilisateurs',
      icon: Icons.people_outline,
      color: const Color(0xFFFF5630),
      secondaryColor: const Color(0xFFFFAB99),
      route: '/users',
      count: '432',
      description: 'Gestion des comptes',
    ),
    CardItem(
      title: 'Statistiques',
      icon: Icons.insert_chart_outlined,
      color: const Color(0xFF6554C0),
      secondaryColor: const Color(0xFFB8ACF6),
      route: '/stats',
      count: '',
      description: 'Analyses des ventes',
    ),
    CardItem(
      title: 'Livreurs',
      icon: Icons.delivery_dining_outlined,
      color: const Color(0xFF00B8D9),
      secondaryColor: const Color(0xFF8FDFF6),
      route: '/delivery',
      count: '18',
      description: 'Gestion des livreurs',
    ),
    CardItem(
      title: 'Promotions',
      icon: Icons.local_offer_outlined,
      color: const Color(0xFFFF8B00),
      secondaryColor: const Color(0xFFFFD580),
      route: '/promotions',
      count: '9',
      description: 'Codes promos & offres',
    ),
    CardItem(
      title: 'Catégories',
      icon: Icons.category_outlined,
      color: const Color(0xFF7A0BC0),
      secondaryColor: const Color(0xFFC87DFF),
      route: '/categories',
      count: '6',
      description: 'Gestion des catégories',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _testAuthentication();
    
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
                            _buildDateChip(theme, isSmallScreen),
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
      color: theme.colorScheme.primary,
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
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: isSmallScreen ? 24 : 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dashboard Admin',
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
                        _getInitials(_user!['nom'] ?? 'Admin'),
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
                icon: Icons.payment_outlined,
                title: 'Ventes du jour',
                value: '€ 1,256.50',
                change: '+12.5%',
                isPositive: true,
                color: theme.colorScheme.primary,
                animationValue: _animation.value,
                delay: 0,
                isSmallScreen: isSmallScreen,
              ),
              _buildSummaryCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Commandes',
                value: '26',
                change: '+8.2%',
                isPositive: true,
                color: const Color(0xFF36B37E),
                animationValue: _animation.value,
                delay: 0.1,
                isSmallScreen: isSmallScreen,
              ),
              _buildSummaryCard(
                icon: Icons.people_outline,
                title: 'Nouveaux clients',
                value: '12',
                change: '-2.4%',
                isPositive: false,
                color: const Color(0xFFFF5630),
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
  final String count;
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