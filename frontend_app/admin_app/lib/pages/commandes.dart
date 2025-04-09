import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CommandesPage extends StatefulWidget {
  const CommandesPage({super.key});

  @override
  State<CommandesPage> createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  bool _isLoading = false;
  late TabController _tabController;
  final List<String> _filterOptions = ['Toutes', 'En cours', 'Livrées', 'Annulées'];
  String _selectedStatus = 'Toutes';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _commandes = [
    {
      'id': 'CMD001',
      'date': '15/05/2023',
      'client': 'Thomas Martin',
      'montant': 829.98,
      'status': 'En cours',
      'produits': [
        {'nom': 'Smartphone XYZ Pro', 'quantite': 1, 'prix': 599.99},
        {'nom': 'Écouteurs sans fil', 'quantite': 2, 'prix': 114.99},
      ],
      'adresse': '15 Rue des Lilas, 75001 Paris, France',
      'telephone': '+33 6 12 34 56 78',
      'paiement': 'Carte Bancaire',
    },
    {
      'id': 'CMD002',
      'date': '14/05/2023',
      'client': 'Sophie Dupont',
      'montant': 1299.99,
      'status': 'Livrée',
      'produits': [
        {'nom': 'Laptop Pro 15"', 'quantite': 1, 'prix': 1299.99},
      ],
      'adresse': '8 Avenue Victor Hugo, 69002 Lyon, France',
      'telephone': '+33 6 98 76 54 32',
      'paiement': 'PayPal',
    },
    {
      'id': 'CMD003',
      'date': '12/05/2023',
      'client': 'Jean Lefevre',
      'montant': 179.98,
      'status': 'Annulée',
      'produits': [
        {'nom': 'Enceinte Bluetooth', 'quantite': 2, 'prix': 89.99},
      ],
      'adresse': '25 Rue du Commerce, 33000 Bordeaux, France',
      'telephone': '+33 6 45 67 89 01',
      'paiement': 'Carte Bancaire',
    },
    {
      'id': 'CMD004',
      'date': '10/05/2023',
      'client': 'Marie Bernard',
      'montant': 599.49,
      'status': 'En cours',
      'produits': [
        {'nom': 'Tablet Média', 'quantite': 1, 'prix': 349.99},
        {'nom': 'Écouteurs sans fil', 'quantite': 1, 'prix': 249.50},
      ],
      'adresse': '12 Boulevard Pasteur, 59000 Lille, France',
      'telephone': '+33 6 23 45 67 89',
      'paiement': 'Carte Bancaire',
    },
    {
      'id': 'CMD005',
      'date': '08/05/2023',
      'client': 'Lucas Dubois',
      'montant': 1429.98,
      'status': 'Livrée',
      'produits': [
        {'nom': 'Laptop Pro 15"', 'quantite': 1, 'prix': 1299.99},
        {'nom': 'Enceinte Bluetooth', 'quantite': 1, 'prix': 129.99},
      ],
      'adresse': '5 Rue de la République, 13001 Marseille, France',
      'telephone': '+33 6 34 56 78 90',
      'paiement': 'Virement bancaire',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filterOptions.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedStatus = _filterOptions[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _commandes.where((order) {
      final matchesStatus = _selectedStatus == 'Toutes' || order['status'] == _selectedStatus;
      final matchesSearch = order['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order['client'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des commandes'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          isScrollable: isSmallScreen,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _filterOptions.map((status) => Tab(text: status)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une commande...',
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
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune commande trouvée',
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
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderCard(order, theme, isSmallScreen);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, ThemeData theme, bool isSmallScreen) {
    // Couleur basée sur le statut
    Color statusColor;
    switch (order['status']) {
      case 'En cours':
        statusColor = Colors.blue;
        break;
      case 'Livrée':
        statusColor = Colors.green;
        break;
      case 'Annulée':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order['id'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['date'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Client',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['client'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Montant',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '€${order['montant'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Produits',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order['produits'].length,
              itemBuilder: (context, index) {
                final product = order['produits'][index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['nom'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product['quantite']} × €${product['prix'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    _showOrderDetailsDialog(context, order);
                  },
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Détails'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                if (order['status'] == 'En cours')
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          _updateOrderStatus(order, 'Livrée');
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Livrer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          _updateOrderStatus(order, 'Annulée');
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Annuler'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                if (order['status'] == 'Livrée' || order['status'] == 'Annulée')
                  ElevatedButton.icon(
                    onPressed: () {
                      _showInvoiceDialog(context, order);
                    },
                    icon: const Icon(Icons.receipt),
                    label: const Text('Facture'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateOrderStatus(Map<String, dynamic> order, String newStatus) {
    setState(() {
      order['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande ${order['id']} marquée comme $newStatus'),
        backgroundColor: newStatus == 'Livrée' ? Colors.green : Colors.red,
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de la commande ${order['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Client', order['client']),
              _buildDetailItem('Date', order['date']),
              _buildDetailItem('Statut', order['status']),
              _buildDetailItem('Paiement', order['paiement']),
              _buildDetailItem('Adresse de livraison', order['adresse']),
              _buildDetailItem('Téléphone', order['telephone']),
              const Divider(height: 24),
              const Text(
                'Produits commandés',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...order['produits'].map<Widget>((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(product['nom']),
                      ),
                      Text(
                        '${product['quantite']} × €${product['prix'].toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '€${order['montant'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.receipt),
            const SizedBox(width: 8),
            Text('Facture ${order['id']}'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('La facture a été générée et peut être téléchargée.'),
              SizedBox(height: 16),
              Text('Voulez-vous également envoyer la facture au client par email?'),
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Facture ${order['id']} téléchargée'),
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Télécharger'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Facture envoyée au client par email'),
                ),
              );
            },
            icon: const Icon(Icons.email),
            label: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
