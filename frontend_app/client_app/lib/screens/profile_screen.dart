import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final userData = await authService.getCurrentUser();
      
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement du profil: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Utiliser AuthProvider pour la déconnexion
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      // Naviguer vers la page de connexion
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _userData == null
          ? const Center(child: Text('Veuillez vous connecter pour voir votre profil'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userData?['nom'] ?? 'Utilisateur',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          _userData?['email'] ?? '',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData?['telephone'] ?? 'Aucun numéro',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('Mes commandes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to orders screen
                      // Navigator.of(context).pushNamed('/orders');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Mes favoris'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to favorites screen
                      // Navigator.of(context).pushNamed('/favorites');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Mes adresses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to addresses screen
                      // Navigator.of(context).pushNamed('/addresses');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Paramètres'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to settings screen
                      // Navigator.of(context).pushNamed('/settings');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Déconnexion',
                            style: TextStyle(color: Colors.white),
                          ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 