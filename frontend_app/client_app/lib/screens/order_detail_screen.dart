import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import '../theme/app_theme.dart' as theme;

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  Map<String, dynamic> _order = {};
  bool _isLoading = true;
  bool _isCancelling = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final order = await _orderService.getOrderDetails(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des détails de la commande: $e';
        _isLoading = false;
      });
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

  // Annuler une commande
  Future<void> _cancelOrder() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Annuler la commande'),
          content: const Text('Êtes-vous sûr de vouloir annuler cette commande ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isCancelling = true;
                });
                
                try {
                  await _orderService.cancelOrder(widget.orderId);
                  
                  setState(() {
                    _isCancelling = false;
                    // Mettre à jour le statut de la commande dans l'état local
                    _order = {
                      ..._order,
                      'statut': 'Annulé',
                      'raisonAnnulation': 'Annulé par le client'
                    };
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Commande annulée avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  setState(() {
                    _isCancelling = false;
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur lors de l\'annulation: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
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
    final statusInfo = _getStatusInfo(_order['statut'] ?? '');
    final bool canCancel = !_isCancelling && 
        (_order['statut'] == 'En préparation' || _order['statut'] == 'En attente de paiement');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${_order['numero'] ?? ''}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrderDetails,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty 
              ? _buildErrorWidget() 
              : _buildOrderDetails(statusInfo, canCancel),
    );
  }

  Widget _buildErrorWidget() {
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
            onPressed: _loadOrderDetails,
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

  Widget _buildOrderDetails(Map<String, dynamic> statusInfo, bool canCancel) {
    final order = _order;
    final produits = order['produits'] as List<dynamic>? ?? [];
    final livraison = order['livraison'] as Map<String, dynamic>? ?? {};
    final paiement = order['paiement'] as Map<String, dynamic>? ?? {};
    
    return Stack(
      children: [
        // Contenu principal avec défilement
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec date et statut
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date de commande
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Commandé le ${_formatDate(order['date'] ?? '')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Statut actuel
                      Row(
                        children: [
                          Icon(statusInfo['icon'], color: statusInfo['color']),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Statut de la commande',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  order['statut'] ?? 'Inconnu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: statusInfo['color'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Raison d'annulation (si applicable)
                      if (order['statut'] == 'Annulé' && order['raisonAnnulation'] != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Raison: ${order['raisonAnnulation']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Produits
              const Text(
                'Produits commandés',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Liste des produits
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < produits.length; i++) ...[
                      _buildProductItem(produits[i]),
                      if (i < produits.length - 1)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informations de livraison
              const Text(
                'Livraison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Méthode de livraison
                      Row(
                        children: [
                          const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              livraison['methode'] ?? 'Livraison standard',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Adresse de livraison
                      const Text(
                        'Adresse de livraison',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${livraison['adresse'] ?? ''}\n'
                        '${livraison['codePostal'] ?? ''} ${livraison['ville'] ?? ''}\n'
                        '${livraison['pays'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Frais de livraison
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Frais de livraison',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${livraison['frais']?.toStringAsFixed(2) ?? '0.00'} €',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Informations de paiement
              const Text(
                'Paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Méthode de paiement
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(paiement['methode'] ?? ''),
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              paiement['methode'] ?? 'Méthode inconnue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPaymentStatusColor(paiement['statut'] ?? '').withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              paiement['statut'] ?? 'Statut inconnu',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getPaymentStatusColor(paiement['statut'] ?? ''),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Récapitulatif des prix
                      const Divider(),
                      
                      const SizedBox(height: 8),
                      
                      // Sous-total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sous-total',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${(_order['total'] - (livraison['frais'] ?? 0.0)).toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Frais de livraison
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Frais de livraison',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${livraison['frais']?.toStringAsFixed(2) ?? '0.00'} €',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${order['total']?.toStringAsFixed(2) ?? '0.00'} €',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Espace supplémentaire en bas pour le bouton d'annulation
              if (canCancel) const SizedBox(height: 100),
            ],
          ),
        ),
        
        // Bouton d'annulation (si applicable)
        if (canCancel)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCancelling ? null : _cancelOrder,
                  icon: _isCancelling 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.cancel),
                  label: Text(_isCancelling ? 'Annulation...' : 'Annuler la commande'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
        
        // Indicateur de chargement pour annulation
        if (_isCancelling)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    final List<dynamic> images = product['images'] ?? [''];
    final String imageUrl = (images.isNotEmpty) ? images[0] : '';
    final double prix = (product['prix'] is num) ? (product['prix'] as num).toDouble() : 0.0;
    final int quantite = (product['quantite'] is num) ? (product['quantite'] as num).toInt() : 1;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit
          Container(
            width: 70,
            height: 70,
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
                      size: 32,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Informations produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['nom'] ?? 'Produit inconnu',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Prix unitaire et quantité
                Row(
                  children: [
                    Text(
                      '${prix.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'x$quantite',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Sous-total
                Text(
                  'Sous-total: ${(prix * quantite).toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'carte bancaire':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet;
      case 'virement bancaire':
        return Icons.account_balance;
      case 'espèces':
        return Icons.payments;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'payé':
        return Colors.green;
      case 'en attente':
        return Colors.orange;
      case 'remboursé':
        return Colors.blue;
      case 'échec':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 