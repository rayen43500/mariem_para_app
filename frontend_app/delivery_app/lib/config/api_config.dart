class ApiConfig {
  // Configuration de l'API
  // URL de base de l'API
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Timeouts pour les requêtes HTTP (en secondes)
  static const int connectTimeout = 15;
  static const int receiveTimeout = 15;
  
  // Pour le débogage - activer les logs détaillés
  static const bool enableDetailedLogs = true;
  
  // Désactiver la vérification de connexion au démarrage
  static const bool skipConnectionCheck = false;
  
  // Headers par défaut pour les requêtes API
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Endpoints API
  static const String loginEndpoint = '/auth/login';
  static const String loginAlternativeEndpoint = '/users/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String profileEndpoint = '/users/me';
  
  // Si true, utilise des données de test en cas d'échec de l'API
  static const bool useTestDataOnFailure = false;
} 