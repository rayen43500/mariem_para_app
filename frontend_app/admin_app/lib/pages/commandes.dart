import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'package:intl/intl.dart';

class CommandesPage extends StatefulWidget {
  const CommandesPage({super.key});

  @override
  State<CommandesPage> createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  final List<String> _filterOptions = ['Toutes', 'En attente', 'Expédiée', 'Livrée', 'Annulée'];
  String _selectedStatus = 'Toutes';
  String _searchQuery = '';
  
  // Instance du service des commandes
  final OrderService _orderService = OrderService();
  
  // Liste des commandes
  List<Order> _commandes = [];

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
    
    // Charger les commandes depuis l'API
    _fetchOrders();
  }
  
  // Méthode pour récupérer les commandes
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final ordersData = await _orderService.getAllOrders();
      
      setState(() {
        _commandes = ordersData.map((json) => Order.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des commandes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Méthode pour mettre à jour le statut d'une commande
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final success = await _orderService.updateOrderStatus(orderId, newStatus);
      
      if (success) {
        // Mettre à jour la commande localement
        setState(() {
          final index = _commandes.indexWhere((order) => order.id == orderId);
          if (index != -1) {
            _commandes[index] = _commandes[index].copyWith(status: newStatus);
          }
        });
        
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut de la commande mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du statut: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _commandes.where((order) {
      final matchesStatus = _selectedStatus == 'Toutes' || order.status == _selectedStatus;
      final matchesSearch = order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
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
        actions: [
          // Bouton de rafraîchissement
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOrders,
            tooltip: 'Rafraîchir',
          ),
        ],
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
                    : RefreshIndicator(
                        onRefresh: _fetchOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _buildOrderCard(order, theme, isSmallScreen);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, ThemeData theme, bool isSmallScreen) {
    // Couleur basée sur le statut
    Color statusColor;
    switch (order.status) {
      case 'En attente':
        statusColor = Colors.orange;
        break;
      case 'Expédiée':
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

    // Formatage de la date
    String formattedDate;
    try {
      // Essayer de parser la date au format ISO
      final date = DateTime.parse(order.date);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      // Si ça échoue, utiliser la chaîne telle quelle
      formattedDate = order.date;
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
                      order.id,
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
                    order.status,
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
            _buildInfoRow('Client', order.clientName, Icons.person),
            _buildInfoRow('Date', formattedDate, Icons.calendar_today),
            _buildInfoRow('Montant', '${order.montant.toStringAsFixed(2)} €', Icons.attach_money),
            _buildInfoRow('Paiement', order.paiement, Icons.payment),
            _buildInfoRow('Téléphone', order.telephone, Icons.phone),
            _buildInfoRow('Adresse', order.adresse, Icons.location_on),
            const Divider(height: 24),
            Text(
              'Produits',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ...order.produits.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: product.image != null && product.image!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                                ),
                              )
                            : const Icon(Icons.shopping_bag, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.nom,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${product.quantite} x ${product.prix.toStringAsFixed(2)} €',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(product.prix * product.quantite).toStringAsFixed(2)} €',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (order.status != 'Livrée' && order.status != 'Annulée')
                  ElevatedButton.icon(
                    onPressed: () => _showStatusUpdateDialog(order),
                    icon: const Icon(Icons.edit),
                    label: const Text('Modifier le statut'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (order.status != 'Annulée')
                  ElevatedButton.icon(
                    onPressed: () => _showDeliveryPersonDialog(order),
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('Assigner livreur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
  
  // Boîte de dialogue pour modifier le statut d'une commande
  void _showStatusUpdateDialog(Order order) {
    final possibleStatuses = ['En attente', 'Expédiée', 'Livrée', 'Annulée'];
    String selectedStatus = order.status;
    
    // Si le statut actuel est "En cours", le convertir en "Expédiée" pour la compatibilité
    if (selectedStatus == 'En cours') {
      selectedStatus = 'Expédiée';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le statut'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: possibleStatuses.map((status) => RadioListTile<String>(
              title: Text(status),
              value: status,
              groupValue: selectedStatus,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(order.id, selectedStatus);
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
  
  // Boîte de dialogue pour assigner un livreur
  void _showDeliveryPersonDialog(Order order) {
    // Temporairement, nous allons utiliser une liste de livreurs statique
    // Dans une future version, on récupérera la liste depuis l'API
    final livreurs = [
      {'id': '1', 'nom': 'Ahmed Benali'},
      {'id': '2', 'nom': 'Sara Mansouri'},
      {'id': '3', 'nom': 'Karim Touré'},
    ];
    
    String? selectedLivreurId = order.livreurId;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigner un livreur'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...livreurs.map((livreur) => RadioListTile<String>(
                title: Text(livreur['nom']!),
                value: livreur['id']!,
                groupValue: selectedLivreurId,
                onChanged: (value) {
                  setState(() {
                    selectedLivreurId = value;
                  });
                },
              )),
              if (order.livreurId != null)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedLivreurId = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                  ),
                  child: const Text('Retirer l\'assignation'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              
              if (selectedLivreurId != null) {
                // Trouver le nom du livreur sélectionné
                final livreurName = livreurs.firstWhere(
                  (l) => l['id'] == selectedLivreurId, 
                  orElse: () => {'id': '', 'nom': ''}
                )['nom'];
                
                // Mettre à jour l'assignation localement
                setState(() {
                  final index = _commandes.indexWhere((o) => o.id == order.id);
                  if (index != -1) {
                    _commandes[index] = _commandes[index].copyWith(
                      livreurId: selectedLivreurId,
                      livreurName: livreurName as String?,
                    );
                  }
                });
                
                // Appeler l'API pour assigner le livreur
                _orderService.assignDeliveryPerson(order.id, selectedLivreurId!).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Livreur assigné avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de l\'assignation du livreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
