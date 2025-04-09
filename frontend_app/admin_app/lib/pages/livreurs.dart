import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LivreursPage extends StatefulWidget {
  const LivreursPage({super.key});

  @override
  State<LivreursPage> createState() => _LivreursPageState();
}

class _LivreursPageState extends State<LivreursPage> {
  final _authService = AuthService();
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedStatus = 'Tous';
  final List<String> _statusOptions = ['Tous', 'Disponible', 'En livraison', 'Inactif'];

  final List<Map<String, dynamic>> _livreurs = [
    {
      'id': 'L001',
      'nom': 'Pierre Dubois',
      'telephone': '+33 6 12 34 56 78',
      'email': 'pierre.dubois@example.com',
      'status': 'Disponible',
      'livraisons': 128,
      'rating': 4.8,
      'zone': 'Paris Centre',
      'vehicule': 'Vélo électrique',
      'photo': 'https://picsum.photos/200/300',
    },
    {
      'id': 'L002',
      'nom': 'Marie Lambert',
      'telephone': '+33 6 23 45 67 89',
      'email': 'marie.lambert@example.com',
      'status': 'En livraison',
      'livraisons': 95,
      'rating': 4.6,
      'zone': 'Paris Nord',
      'vehicule': 'Scooter',
      'photo': 'https://picsum.photos/200/300',
    },
    {
      'id': 'L003',
      'nom': 'Julien Moreau',
      'telephone': '+33 6 34 56 78 90',
      'email': 'julien.moreau@example.com',
      'status': 'Disponible',
      'livraisons': 210,
      'rating': 4.9,
      'zone': 'Paris Sud',
      'vehicule': 'Voiture électrique',
      'photo': 'https://picsum.photos/200/300',
    },
    {
      'id': 'L004',
      'nom': 'Sophie Martin',
      'telephone': '+33 6 45 67 89 01',
      'email': 'sophie.martin@example.com',
      'status': 'Inactif',
      'livraisons': 45,
      'rating': 4.2,
      'zone': 'Paris Ouest',
      'vehicule': 'Vélo',
      'photo': 'https://picsum.photos/200/300',
    },
    {
      'id': 'L005',
      'nom': 'Antoine Legrand',
      'telephone': '+33 6 56 78 90 12',
      'email': 'antoine.legrand@example.com',
      'status': 'En livraison',
      'livraisons': 173,
      'rating': 4.7,
      'zone': 'Paris Centre',
      'vehicule': 'Moto',
      'photo': 'https://picsum.photos/200/300',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLivreurs = _livreurs.where((livreur) {
      final matchesStatus = _selectedStatus == 'Tous' || livreur['status'] == _selectedStatus;
      final matchesSearch = livreur['nom'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          livreur['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des livreurs'),
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
                    hintText: 'Rechercher un livreur...',
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
                    itemCount: _statusOptions.length,
                    itemBuilder: (context, index) {
                      final status = _statusOptions[index];
                      final isSelected = status == _selectedStatus;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedStatus = status;
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
                : filteredLivreurs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delivery_dining_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun livreur trouvé',
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
                        itemCount: filteredLivreurs.length,
                        itemBuilder: (context, index) {
                          final livreur = filteredLivreurs[index];
                          return _buildLivreurCard(livreur, theme, isSmallScreen);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logique pour ajouter un nouveau livreur
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLivreurCard(Map<String, dynamic> livreur, ThemeData theme, bool isSmallScreen) {
    Color statusColor;
    switch (livreur['status']) {
      case 'Disponible':
        statusColor = Colors.green;
        break;
      case 'En livraison':
        statusColor = Colors.blue;
        break;
      case 'Inactif':
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
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(livreur['photo']),
                  onBackgroundImageError: (_, __) {},
                  child: Container(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              livreur['nom'],
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
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              livreur['status'],
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            livreur['zone'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.directions_bike_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            livreur['vehicule'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  Icons.delivery_dining,
                  'Livraisons',
                  livreur['livraisons'].toString(),
                ),
                _buildInfoItem(
                  Icons.star,
                  'Évaluation',
                  '${livreur['rating']} / 5',
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone),
                      onPressed: () {
                        // Logique pour appeler le livreur
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        // Logique pour modifier le livreur
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.blue,
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
