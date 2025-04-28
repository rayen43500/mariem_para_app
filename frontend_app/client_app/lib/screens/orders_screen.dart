import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';
import '../theme/app_theme.dart' as theme;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadOrders();
  }

  Future<void> _checkAuthAndLoadOrders() async {
    try {
      // Vérifier si l'utilisateur est authentifié via le provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Utiliser la nouvelle méthode qui vérifie et rafraîchit l'état d'authentification
      _isAuthenticated = await authProvider.checkAuthentication();
      
      if (_isAuthenticated) {
        await _loadOrders();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Veuillez vous connecter pour voir vos commandes';
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification de l\'authentification: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de la vérification de l\'authentification';
        _isAuthenticated = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orders = await _orderService.getUserOrders();
      
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur de chargement des commandes: $e');
      
      String message = 'Erreur lors du chargement des commandes';
      bool authError = false;
      
      // Vérifier si c'est une erreur d'authentification
      if (e.toString().contains('Token non trouvé') || 
          e.toString().contains('reconnecter') ||
          e.toString().contains('401')) {
        message = 'Veuillez vous connecter pour voir vos commandes';
        authError = true;
      }
      
      if (mounted) {
        setState(() {
          _errorMessage = message;
          _isLoading = false;
          if (authError) _isAuthenticated = false;
        });
      }
    }
  }

  // Formatter une date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Obtenir la couleur et l'icône pour un statut donné
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'en préparation':
        return {
          'color': Colors.blue,
          'icon': Icons.inventory,
          'background': Colors.blue.withOpacity(0.1),
        };
      case 'expédié':
        return {
          'color': Colors.orange,
          'icon': Icons.local_shipping,
          'background': Colors.orange.withOpacity(0.1),
        };
      case 'livré':
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
          'background': Colors.green.withOpacity(0.1),
        };
      case 'annulé':
        return {
          'color': Colors.red,
          'icon': Icons.cancel,
          'background': Colors.red.withOpacity(0.1),
        };
      case 'en attente de paiement':
        return {
          'color': Colors.purple,
          'icon': Icons.payment,
          'background': Colors.purple.withOpacity(0.1),
        };
      default:
        return {
          'color': Colors.grey,
          'icon': Icons.info,
          'background': Colors.grey.withOpacity(0.1),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty 
              ? _buildErrorWidget() 
              : _orders.isEmpty 
                  ? _buildEmptyOrdersWidget() 
                  : _buildOrdersList(),
    );
  }

  Widget _buildErrorWidget() {
    // Si l'erreur est due à l'authentification, montrer un message spécifique
    if (!_isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 70,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Connectez-vous pour voir vos commandes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous devez être connecté pour accéder à votre historique de commandes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Naviguer vers l'écran de connexion
                // Utiliser pushNamedAndRemoveUntil pour effacer l'historique de navigation
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', 
                  (route) => false, // Cela efface toutes les routes précédentes
                  arguments: {'fromCommandes': true} // Indiquer que nous venons de l'écran des commandes
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Se connecter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: theme.AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    }
    
    // Sinon, afficher l'erreur standard
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Oups! Une erreur est survenue',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Vous n\'avez pas encore de commandes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Vos commandes apparaîtront ici une fois que vous aurez effectué un achat. Parcourez notre catalogue pour trouver des produits qui vous plaisent.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Retour à l'écran principal
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Commencer vos achats'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: theme.AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: Column(
        children: [
          // Liste des commandes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final statusInfo = _getStatusInfo(order['statut'] ?? '');
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(orderId: order['_id']),
                        ),
                      ).then((_) => _loadOrders()); // Rafraîchir au retour
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Entête avec numéro de commande et date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Commande #${order['numero']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatDate(order['date']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Badge de statut
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusInfo['background'],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  statusInfo['icon'],
                                  size: 14,
                                  color: statusInfo['color'],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  order['statut'] ?? 'Inconnu',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo['color'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Aperçu des produits
                          if (order['produits'] != null && (order['produits'] as List).isNotEmpty) ...[
                            const Text(
                              'Produits',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Afficher les premières images des produits
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (order['produits'] as List).length,
                                itemBuilder: (context, i) {
                                  final product = (order['produits'] as List)[i];
                                  final List<dynamic> images = product['images'] ?? [''];
                                  final String imageUrl = (images.isNotEmpty) ? images[0] : '';
                                  
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.image_not_supported_outlined,
                                              size: 24,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                          
                          // Prix total et bouton voir détails
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${order['total']?.toStringAsFixed(2) ?? '0.00'} €',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailScreen(orderId: order['_id']),
                                    ),
                                  ).then((_) => _loadOrders()); // Rafraîchir au retour
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  foregroundColor: theme.AppTheme.primaryColor,
                                  backgroundColor: theme.AppTheme.primaryColor.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Voir détails',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 