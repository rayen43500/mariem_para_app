import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/produits.dart';
import 'pages/commandes.dart';
import 'pages/utilisateurs.dart';
import 'pages/statistique.dart';
import 'pages/livreurs.dart';
import 'pages/promotions.dart';
import 'pages/categorie.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A6FFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const AdminDashboardPage(),
        '/products': (context) => const ProduitsPage(),
        '/orders': (context) => const CommandesPage(),
        '/users': (context) => const UtilisateursPage(),
        '/stats': (context) => const StatistiquePage(),
        '/delivery': (context) => const LivreursPage(),
        '/promotions': (context) => const PromotionsPage(),
        '/categories': (context) => const CategoriePage(),
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
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (!isLoggedIn) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });
      return;
    }

    // Verifier que le token est toujours valide
    final isTokenValid = await _authService.validateToken();
    
    if (!isTokenValid) {
      await _authService.logout();
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });
      return;
    }

    final user = await _authService.getCurrentUser();
    final isAdmin = user?['role'] == 'Admin';

    setState(() {
      _isLoading = false;
      _isLoggedIn = true;
      _isAdmin = isAdmin;
    });
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Accès non autorisé',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous n\'avez pas les droits d\'administration nécessaires',
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
                child: const Text('Déconnexion'),
              ),
            ],
          ),
        ),
      );
    }

    return const AdminDashboardPage();
  }
}
