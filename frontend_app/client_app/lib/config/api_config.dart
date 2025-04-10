class ApiConfig {
  // Configuration de l'URL de l'API
  // Utilisez localhost pour le développement local
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Timeouts (en millisecondes)
  static const int connectionTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000;    // 30 secondes
  
  // Pour le débogage - activer les logs détaillés
  static const bool enableDetailedLogs = true;
  
  // Si true, utilise des données de test en cas d'échec de l'API
  static const bool useTestDataOnFailure = true;
} 