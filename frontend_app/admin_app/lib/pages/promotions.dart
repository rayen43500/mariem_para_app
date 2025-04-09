import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final _authService = AuthService();
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedType = 'Tous';
  final List<String> _typeOptions = ['Tous', 'Pourcentage', 'Montant fixe', 'Livraison gratuite'];

  final List<Map<String, dynamic>> _promotions = [
    {
      'id': 'PROMO001',
      'code': 'BIENVENUE20',
      'description': '20% de réduction sur votre première commande',
      'type': 'Pourcentage',
      'valeur': 20,
      'dateDebut': '01/05/2023',
      'dateFin': '31/12/2023',
      'minAchat': 50,
      'utilisations': 124,
      'limiteUtilisations': 500,
      'actif': true,
    },
    {
      'id': 'PROMO002',
      'code': 'ETE15',
      'description': '15% de réduction sur les accessoires d\'été',
      'type': 'Pourcentage',
      'valeur': 15,
      'dateDebut': '01/06/2023',
      'dateFin': '31/08/2023',
      'minAchat': 30,
      'utilisations': 87,
      'limiteUtilisations': 200,
      'actif': true,
    },
    {
      'id': 'PROMO003',
      'code': 'FREESHIP',
      'description': 'Livraison gratuite sans minimum d\'achat',
      'type': 'Livraison gratuite',
      'valeur': 0,
      'dateDebut': '15/05/2023',
      'dateFin': '15/06/2023',
      'minAchat': 0,
      'utilisations': 210,
      'limiteUtilisations': 300,
      'actif': true,
    },
    {
      'id': 'PROMO004',
      'code': 'REDUC10',
      'description': '10€ de réduction sur votre commande',
      'type': 'Montant fixe',
      'valeur': 10,
      'dateDebut': '01/04/2023',
      'dateFin': '30/06/2023',
      'minAchat': 60,
      'utilisations': 156,
      'limiteUtilisations': 250,
      'actif': true,
    },
    {
      'id': 'PROMO005',
      'code': 'HIVER2023',
      'description': '25% de réduction sur la collection hiver',
      'type': 'Pourcentage',
      'valeur': 25,
      'dateDebut': '01/11/2023',
      'dateFin': '31/01/2024',
      'minAchat': 80,
      'utilisations': 0,
      'limiteUtilisations': 150,
      'actif': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPromotions = _promotions.where((promo) {
      final matchesType = _selectedType == 'Tous' || promo['type'] == _selectedType;
      final matchesSearch = promo['code'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          promo['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des promotions'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    hintText: 'Rechercher une promotion...',
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
                    itemCount: _typeOptions.length,
                    itemBuilder: (context, index) {
                      final type = _typeOptions[index];
                      final isSelected = type == _selectedType;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type;
                              });
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPromotions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune promotion trouvée',
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
                        itemCount: filteredPromotions.length,
                        itemBuilder: (context, index) {
                          final promo = filteredPromotions[index];
                          return _buildPromoCard(promo, theme, isSmallScreen);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logique pour ajouter une nouvelle promotion
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPromoCard(Map<String, dynamic> promo, ThemeData theme, bool isSmallScreen) {
    final bool isActive = promo['actif'];
    final now = DateTime.now();
    final dateDebut = _parseDate(promo['dateDebut']);
    final dateFin = _parseDate(promo['dateFin']);
    final bool isExpired = dateFin.isBefore(now);
    final bool isUpcoming = dateDebut.isAfter(now);
    
    Color statusColor;
    String statusText;
    
    if (!isActive) {
      statusColor = Colors.grey;
      statusText = 'Inactif';
    } else if (isExpired) {
      statusColor = Colors.red;
      statusText = 'Expiré';
    } else if (isUpcoming) {
      statusColor = Colors.orange;
      statusText = 'À venir';
    } else {
      statusColor = Colors.green;
      statusText = 'Actif';
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo['code'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo['description'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPromoDetails(promo, theme),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Utilisations: ${promo['utilisations']}/${promo['limiteUtilisations']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        // Logique pour modifier la promotion
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(isActive ? Icons.toggle_on : Icons.toggle_off),
                      onPressed: () {
                        // Logique pour activer/désactiver la promotion
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: isActive ? theme.colorScheme.primary : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        // Logique pour supprimer la promotion
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoDetails(Map<String, dynamic> promo, ThemeData theme) {
    Color typeColor;
    IconData typeIcon;

    switch (promo['type']) {
      case 'Pourcentage':
        typeColor = Colors.blue;
        typeIcon = Icons.percent;
        break;
      case 'Montant fixe':
        typeColor = Colors.green;
        typeIcon = Icons.euro;
        break;
      case 'Livraison gratuite':
        typeColor = Colors.orange;
        typeIcon = Icons.local_shipping;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.tag;
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        Chip(
          avatar: Icon(
            typeIcon,
            size: 16,
            color: typeColor,
          ),
          label: Text(
            '${promo['type']} ${promo['type'] == 'Pourcentage' ? '${promo['valeur']}%' : promo['type'] == 'Montant fixe' ? '${promo['valeur']}€' : ''}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          backgroundColor: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        if (promo['minAchat'] > 0)
          Chip(
            avatar: Icon(
              Icons.shopping_cart,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              'Min. ${promo['minAchat']}€',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            backgroundColor: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        Chip(
          avatar: Icon(
            Icons.date_range,
            size: 16,
            color: Colors.purple,
          ),
          label: Text(
            '${promo['dateDebut']} - ${promo['dateFin']}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          backgroundColor: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }
}
