import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UtilisateursPage extends StatefulWidget {
  const UtilisateursPage({super.key});

  @override
  State<UtilisateursPage> createState() => _UtilisateursPageState();
}

class _UtilisateursPageState extends State<UtilisateursPage> {
  final _authService = AuthService();
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedRole = 'Tous';
  final List<String> _roles = ['Tous', 'Admin', 'Client'];

  final List<Map<String, dynamic>> _utilisateurs = [
    {
      'id': 'U001',
      'nom': 'Thomas Martin',
      'email': 'thomas.martin@example.com',
      'telephone': '+33 6 12 34 56 78',
      'dateInscription': '10/01/2023',
      'role': 'Client',
      'status': 'Actif',
      'commandes': 5,
      'adresse': '15 Rue des Lilas, 75001 Paris, France',
    },
    {
      'id': 'U002',
      'nom': 'Sophie Dupont',
      'email': 'sophie.dupont@example.com',
      'telephone': '+33 6 98 76 54 32',
      'dateInscription': '15/02/2023',
      'role': 'Client',
      'status': 'Actif',
      'commandes': 3,
      'adresse': '8 Avenue Victor Hugo, 69002 Lyon, France',
    },
    {
      'id': 'U003',
      'nom': 'Jean Lefevre',
      'email': 'jean.lefevre@example.com',
      'telephone': '+33 6 45 67 89 01',
      'dateInscription': '20/03/2023',
      'role': 'Client',
      'status': 'Inactif',
      'commandes': 1,
      'adresse': '25 Rue du Commerce, 33000 Bordeaux, France',
    },
    {
      'id': 'U004',
      'nom': 'Marie Bernard',
      'email': 'marie.bernard@example.com',
      'telephone': '+33 6 23 45 67 89',
      'dateInscription': '05/04/2023',
      'role': 'Client',
      'status': 'Actif',
      'commandes': 2,
      'adresse': '12 Boulevard Pasteur, 59000 Lille, France',
    },
    {
      'id': 'U005',
      'nom': 'Admin Principal',
      'email': 'admin@example.com',
      'telephone': '+33 6 00 00 00 00',
      'dateInscription': '01/01/2023',
      'role': 'Admin',
      'status': 'Actif',
      'commandes': 0,
      'adresse': '1 Place de l\'Administration, 75001 Paris, France',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _utilisateurs.where((user) {
      final matchesRole = _selectedRole == 'Tous' || user['role'] == _selectedRole;
      final matchesSearch = user['nom'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user['email'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesRole && matchesSearch;
    }).toList();

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
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
                    hintText: 'Rechercher un utilisateur...',
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
                    itemCount: _roles.length,
                    itemBuilder: (context, index) {
                      final role = _roles[index];
                      final isSelected = role == _selectedRole;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(role),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedRole = role;
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
                : filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun utilisateur trouvé',
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
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserCard(user, theme, isSmallScreen);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditUserDialog(context);
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, ThemeData theme, bool isSmallScreen) {
    // Couleur basée sur le statut
    final isActive = user['status'] == 'Actif';
    final statusColor = isActive ? Colors.green : Colors.red;
    final roleColor = user['role'] == 'Admin' ? Colors.deepPurple : Colors.blue;

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
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    _getInitials(user['nom']),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                              user['nom'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user['role'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: roleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user['status'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user['telephone'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
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
                  Icons.calendar_today,
                  'Inscrit le',
                  user['dateInscription'],
                ),
                _buildInfoItem(
                  Icons.shopping_cart,
                  'Commandes',
                  user['commandes'].toString(),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      onPressed: () {
                        _showUserDetailsDialog(context, user);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        _showAddEditUserDialog(context, user: user);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.block_outlined),
                      onPressed: () {
                        _toggleUserStatus(user);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: isActive ? Colors.red : Colors.green,
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

  void _toggleUserStatus(Map<String, dynamic> user) {
    final newStatus = user['status'] == 'Actif' ? 'Inactif' : 'Actif';
    setState(() {
      user['status'] = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${user['nom']} est maintenant ${newStatus.toLowerCase()}'),
        backgroundColor: newStatus == 'Actif' ? Colors.green : Colors.red,
      ),
    );
  }

  void _showUserDetailsDialog(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de ${user['nom']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('ID', user['id']),
              _buildDetailItem('Nom', user['nom']),
              _buildDetailItem('Email', user['email']),
              _buildDetailItem('Téléphone', user['telephone']),
              _buildDetailItem('Adresse', user['adresse']),
              _buildDetailItem('Date d\'inscription', user['dateInscription']),
              _buildDetailItem('Rôle', user['role']),
              _buildDetailItem('Statut', user['status']),
              _buildDetailItem('Nombre de commandes', user['commandes'].toString()),
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddEditUserDialog(context, user: user);
            },
            child: const Text('Modifier'),
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

  void _showAddEditUserDialog(BuildContext context, {Map<String, dynamic>? user}) {
    final isEditing = user != null;
    
    // Si on édite, on initialise avec les valeurs existantes
    final TextEditingController nameController = TextEditingController(text: isEditing ? user['nom'] : '');
    final TextEditingController emailController = TextEditingController(text: isEditing ? user['email'] : '');
    final TextEditingController phoneController = TextEditingController(text: isEditing ? user['telephone'] : '');
    final TextEditingController addressController = TextEditingController(text: isEditing ? user['adresse'] : '');
    
    String selectedRole = isEditing ? user['role'] : 'Client';
    bool isActive = isEditing ? user['status'] == 'Actif' : true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Ex: Jean Dupont',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Ex: jean.dupont@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    hintText: 'Ex: +33 6 12 34 56 78',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    hintText: 'Ex: 15 Rue des Lilas, 75001 Paris',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                  ),
                  items: ['Admin', 'Client'].map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Compte actif'),
                  value: isActive,
                  onChanged: (value) {
                    if (value != null) {
                      isActive = value;
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
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
            ElevatedButton(
              onPressed: () {
                // En production, appeler une API pour sauvegarder
                // Pour l'exemple, on met simplement à jour la liste locale
                setState(() {
                  if (isEditing) {
                    // Mettre à jour l'utilisateur existant
                    user['nom'] = nameController.text;
                    user['email'] = emailController.text;
                    user['telephone'] = phoneController.text;
                    user['adresse'] = addressController.text;
                    user['role'] = selectedRole;
                    user['status'] = isActive ? 'Actif' : 'Inactif';
                  } else {
                    // Ajouter un nouvel utilisateur
                    _utilisateurs.add({
                      'id': 'U${(100 + _utilisateurs.length).toString().padLeft(3, '0')}',
                      'nom': nameController.text,
                      'email': emailController.text,
                      'telephone': phoneController.text,
                      'adresse': addressController.text,
                      'dateInscription': _getCurrentDate(),
                      'role': selectedRole,
                      'status': isActive ? 'Actif' : 'Inactif',
                      'commandes': 0,
                    });
                  }
                });
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
            ),
          ],
        );
      },
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (name.length >= 2) {
      return name.substring(0, 2);
    } else {
      return name;
    }
  }
}
