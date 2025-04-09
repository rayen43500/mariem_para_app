import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CategoriePage extends StatefulWidget {
  const CategoriePage({super.key});

  @override
  State<CategoriePage> createState() => _CategoriePageState();
}

class _CategoriePageState extends State<CategoriePage> {
  final _authService = AuthService();
  bool _isLoading = false;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'CAT1',
      'nom': 'Électronique',
      'icon': Icons.devices,
      'couleur': Colors.blue,
      'produits': 35,
      'description': 'Smartphones, tablettes et autres appareils électroniques',
      'actif': true,
    },
    {
      'id': 'CAT2',
      'nom': 'Accessoires',
      'icon': Icons.headphones,
      'couleur': Colors.orange,
      'produits': 48,
      'description': 'Coques, chargeurs, écouteurs et autres accessoires',
      'actif': true,
    },
    {
      'id': 'CAT3',
      'nom': 'Informatique',
      'icon': Icons.computer,
      'couleur': Colors.green,
      'produits': 20,
      'description': 'Ordinateurs portables, PC de bureau et périphériques',
      'actif': true,
    },
    {
      'id': 'CAT4',
      'nom': 'Wearables',
      'icon': Icons.watch,
      'couleur': Colors.purple,
      'produits': 12,
      'description': 'Montres connectées et bracelets d\'activité',
      'actif': true,
    },
    {
      'id': 'CAT5',
      'nom': 'Audio',
      'icon': Icons.speaker,
      'couleur': Colors.red,
      'produits': 15,
      'description': 'Enceintes, casques audio et systèmes audio',
      'actif': true,
    },
    {
      'id': 'CAT6',
      'nom': 'Maison intelligente',
      'icon': Icons.home,
      'couleur': Colors.teal,
      'produits': 8,
      'description': 'Produits connectés pour la maison',
      'actif': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _categories.where((category) {
      return category['nom'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des catégories'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une catégorie...',
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
                : filteredCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune catégorie trouvée',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isSmallScreen ? 1 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isSmallScreen ? 2 : 1.5,
                        ),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          return _buildCategoryCard(category, theme);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditCategoryDialog(context);
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, ThemeData theme) {
    final isActive = category['actif'];
    final color = category['couleur'];
    final iconData = category['icon'] as IconData;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          _showCategoryDetailDialog(context, category);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    radius: 24,
                    child: Icon(
                      iconData,
                      color: color,
                      size: 24,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isActive ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showAddEditCategoryDialog(context, category: category);
                          } else if (value == 'toggle') {
                            setState(() {
                              category['actif'] = !category['actif'];
                            });
                          } else if (value == 'delete') {
                            _showDeleteConfirmDialog(context, category);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  isActive ? Icons.toggle_off : Icons.toggle_on,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(isActive ? 'Désactiver' : 'Activer'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                category['nom'],
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                category['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category['produits']} produits',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetailDialog(BuildContext context, Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category['nom']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category['description'],
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Statistiques',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nombre de produits:',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${category['produits']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statut:',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  category['actif'] ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: category['actif'] ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
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
              _showAddEditCategoryDialog(context, category: category);
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showAddEditCategoryDialog(BuildContext context, {Map<String, dynamic>? category}) {
    final isEditing = category != null;
    final TextEditingController nameController = TextEditingController(text: isEditing ? category['nom'] : '');
    final TextEditingController descriptionController = TextEditingController(text: isEditing ? category['description'] : '');
    bool isActive = isEditing ? category['actif'] : true;
    Color selectedColor = isEditing ? category['couleur'] : Colors.blue;
    IconData selectedIcon = isEditing ? category['icon'] : Icons.category;

    final List<Color> colorOptions = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    final List<IconData> iconOptions = [
      Icons.devices,
      Icons.headphones,
      Icons.computer,
      Icons.watch,
      Icons.speaker,
      Icons.home,
      Icons.phone_android,
      Icons.tv,
      Icons.camera_alt,
      Icons.videogame_asset,
      Icons.sports_esports,
      Icons.memory,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Modifier la catégorie' : 'Ajouter une catégorie'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  hintText: 'Ex: Électronique',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Ex: Smartphones, tablettes et autres appareils électroniques',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('Couleur'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colorOptions.map((color) {
                  return InkWell(
                    onTap: () {
                      selectedColor = color;
                    },
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 16,
                      child: selectedColor == color
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Icône'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: iconOptions.map((icon) {
                  return InkWell(
                    onTap: () {
                      selectedIcon = icon;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon ? selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: selectedIcon == icon
                            ? Border.all(
                                color: selectedColor,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: selectedIcon == icon ? selectedColor : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Catégorie active'),
                value: isActive,
                onChanged: (value) {
                  if (value != null) {
                    isActive = value;
                  }
                },
                contentPadding: EdgeInsets.zero,
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
              // Valider et sauvegarder les changements
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le nom de la catégorie est requis')),
                );
                return;
              }

              setState(() {
                if (isEditing) {
                  // Mettre à jour la catégorie existante
                  category['nom'] = name;
                  category['description'] = description;
                  category['couleur'] = selectedColor;
                  category['icon'] = selectedIcon;
                  category['actif'] = isActive;
                } else {
                  // Ajouter une nouvelle catégorie
                  _categories.add({
                    'id': 'CAT${_categories.length + 1}',
                    'nom': name,
                    'description': description,
                    'couleur': selectedColor,
                    'icon': selectedIcon,
                    'produits': 0,
                    'actif': isActive,
                  });
                }
              });
              
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la catégorie'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer la catégorie "${category['nom']}" ? Cette action est irréversible et supprimera également tous les liens avec les produits associés.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _categories.removeWhere((item) => item['id'] == category['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Catégorie "${category['nom']}" supprimée'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
