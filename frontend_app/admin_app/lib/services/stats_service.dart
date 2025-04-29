import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import 'auth_service.dart';
import 'dashboard_service.dart';

class StatsService {
  final AuthService _authService = AuthService();
  final DashboardService _dashboardService = DashboardService();
  final String baseUrl = ApiConfig.baseUrl;
  final _logger = Logger();

  // Récupérer les statistiques générales
  Future<Map<String, dynamic>> getStats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Récupérer les données du dashboard pour les compteurs
      final dashboardStats = await _dashboardService.getDashboardStats();
      
      // Récupérer d'autres statistiques si disponibles...
      // Pour l'instant, on utilise les données du dashboard et on ajoute des statistiques fictives pour le reste
      
      return {
        'revenuTotal': 12586.45, // À remplacer par une vraie API
        'revenuComparaison': 8.7,
        'commandesTotal': dashboardStats['commandes'],
        'commandesComparaison': 12.4,
        'clientsTotal': dashboardStats['utilisateurs'],
        'clientsComparaison': 5.2,
        'vuesProduits': 1245,
        'vuesComparaison': 15.8,
        'tauxConversion': 3.2,
        'tauxConversionComparaison': 0.8,
        // Les autres données peuvent rester fictives pour le moment
        'produitsBestSellers': await _getBestSellingProducts(),
        'ventesMensuelles': [
          {'mois': 'Jan', 'ventes': 8240.50},
          {'mois': 'Fév', 'ventes': 7890.30},
          {'mois': 'Mar', 'ventes': 9120.75},
          {'mois': 'Avr', 'ventes': 8450.20},
          {'mois': 'Mai', 'ventes': 10250.60},
          {'mois': 'Juin', 'ventes': 11340.80},
          {'mois': 'Juil', 'ventes': 12580.45},
          {'mois': 'Août', 'ventes': 9870.30},
          {'mois': 'Sep', 'ventes': 10740.55},
          {'mois': 'Oct', 'ventes': 11890.70},
          {'mois': 'Nov', 'ventes': 13450.90},
          {'mois': 'Déc', 'ventes': 15780.25},
        ],
        'ventesParCategorie': await _getSalesByCategory(),
      };
    } catch (e) {
      _logger.e('Erreur dans getStats: $e');
      // Retourner des données par défaut en cas d'erreur
      return {
        'revenuTotal': 0,
        'revenuComparaison': 0,
        'commandesTotal': 0,
        'commandesComparaison': 0,
        'clientsTotal': 0,
        'clientsComparaison': 0,
        'vuesProduits': 0,
        'vuesComparaison': 0,
        'tauxConversion': 0,
        'tauxConversionComparaison': 0,
        'produitsBestSellers': [],
        'ventesMensuelles': [],
        'ventesParCategorie': [],
      };
    }
  }

  // Obtenir les produits les plus vendus
  Future<List<Map<String, dynamic>>> _getBestSellingProducts() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Tentative de récupération depuis l'API
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/best-sellers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } 
      
      // Si l'API n'est pas disponible, retourner des données fictives
      return [
        {'nom': 'Smartphone XYZ Pro', 'ventes': 28, 'revenu': 16799.72},
        {'nom': 'Écouteurs sans fil', 'ventes': 45, 'revenu': 5849.55},
        {'nom': 'Laptop Pro 15"', 'ventes': 12, 'revenu': 15599.88},
        {'nom': 'Montre connectée', 'ventes': 24, 'revenu': 5988.00},
        {'nom': 'Enceinte Bluetooth', 'ventes': 32, 'revenu': 2559.68},
      ];
    } catch (e) {
      _logger.e('Erreur lors de la récupération des produits les plus vendus: $e');
      return [
        {'nom': 'Smartphone XYZ Pro', 'ventes': 28, 'revenu': 16799.72},
        {'nom': 'Écouteurs sans fil', 'ventes': 45, 'revenu': 5849.55},
        {'nom': 'Laptop Pro 15"', 'ventes': 12, 'revenu': 15599.88},
        {'nom': 'Montre connectée', 'ventes': 24, 'revenu': 5988.00},
        {'nom': 'Enceinte Bluetooth', 'ventes': 32, 'revenu': 2559.68},
      ];
    }
  }

  // Obtenir les ventes par catégorie
  Future<List<Map<String, dynamic>>> _getSalesByCategory() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Tentative de récupération depuis l'API
      final response = await http.get(
        Uri.parse('$baseUrl/api/categories/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      
      // Si l'API n'est pas disponible, retourner des données fictives
      return [
        {'categorie': 'Électronique', 'pourcentage': 45},
        {'categorie': 'Accessoires', 'pourcentage': 25},
        {'categorie': 'Informatique', 'pourcentage': 15},
        {'categorie': 'Wearables', 'pourcentage': 10},
        {'categorie': 'Audio', 'pourcentage': 5},
      ];
    } catch (e) {
      _logger.e('Erreur lors de la récupération des ventes par catégorie: $e');
      return [
        {'categorie': 'Électronique', 'pourcentage': 45},
        {'categorie': 'Accessoires', 'pourcentage': 25},
        {'categorie': 'Informatique', 'pourcentage': 15},
        {'categorie': 'Wearables', 'pourcentage': 10},
        {'categorie': 'Audio', 'pourcentage': 5},
      ];
    }
  }
} 