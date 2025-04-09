import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.blueAccent,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/admin-dashboard': (context) => const AdminDashboardPage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Vérifie si l'utilisateur est connecté (token valide + rôle admin)
      final isLoggedIn = await _authService.isLoggedIn();
      final isTokenValid = await _authService.validateToken();
      
      final isAuthenticated = isLoggedIn && isTokenValid;
      
      setState(() {
        _isLoggedIn = isAuthenticated;
        _isAdmin = isAuthenticated; // Nous vérifions déjà le rôle Admin dans isLoggedIn()
        _isLoading = false;
      });
      
      if (_isLoggedIn && mounted) {
        // Afficher des informations utiles pour le débogage
        final user = await _authService.getCurrentUser();
        print('Utilisateur connecté: ${user?['nom']} (${user?['role']})');
        print('Token valide: $isTokenValid');
      }
    } catch (e) {
      print('Erreur lors de la vérification de l\'authentification: $e');
      setState(() {
        _isLoggedIn = false;
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isLoggedIn) {
      return const LoginPage();
    }
    
    if (!_isAdmin) {
      // Si l'utilisateur est connecté mais n'est pas admin
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Accès non autorisé',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vous n\'avez pas les droits administrateur nécessaires.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await _authService.logout();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      );
    }

    return const AdminDashboardPage();
  }
}
