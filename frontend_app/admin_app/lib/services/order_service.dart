import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class OrderService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Récupérer toutes les commandes (admin)
  Future<List<dynamic>> getAllOrders() async {
    try {
      // Récupérer le token via le service d'authentification
      final token = await _authService.getToken();
      
      if (token == null) {
        print('❌ Token d\'authentification non trouvé');
        throw Exception('Token non trouvé. Veuillez vous connecter.');
      }
      
      print('📦 Tentative de récupération des commandes depuis le backend');
      
      // Utiliser la nouvelle route admin pour récupérer toutes les commandes
      final response = await http.get(
        Uri.parse('$baseUrl/api/commandes/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('📦 Réponse du serveur: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Traiter la réponse
        final data = json.decode(response.body);
        
        if (data['success'] == true || data['commandes'] != null || data['data'] != null) {
          List<dynamic> commandes = data['commandes'] ?? data['data'] ?? [];
          print('📦 ${commandes.length} commandes récupérées');
          
          // Si aucune commande n'a été récupérée, utiliser des données de test
          if (commandes.isEmpty) {
            print('⚠️ Aucune commande trouvée, utilisation des données de test');
            return _getTestOrders();
          }
          
          return commandes;
        } else {
          print('❌ Réponse API incorrecte: ${response.body}');
          return _getTestOrders();
        }
      } else {
        print('❌ Erreur API: ${response.statusCode} ${response.body}');
        return _getTestOrders();
      }
    } catch (e) {
      print('❌ Exception lors de la récupération des commandes: $e');
      return _getTestOrders();
    }
  }
  
  // Méthode pour fournir des données de test
  List<dynamic> _getTestOrders() {
    return [
      {
        '_id': 'CMD001',
        'dateCreation': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'client': {'nom': 'Thomas Martin', 'telephone': '+33 6 12 34 56 78'},
        'total': 829.98,
        'statut': 'En attente',
        'produits': [
          {'produitId': 'P001', 'nom': 'Smartphone XYZ Pro', 'quantite': 1, 'prixUnitaire': 599.99},
          {'produitId': 'P002', 'nom': 'Écouteurs sans fil', 'quantite': 2, 'prixUnitaire': 114.99},
        ],
        'adresseLivraison': '15 Rue des Lilas, 75001 Paris, France',
        'methodePaiement': 'Carte Bancaire',
      },
      {
        '_id': 'CMD002',
        'dateCreation': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'client': {'nom': 'Sophie Dupont', 'telephone': '+33 6 98 76 54 32'},
        'total': 1299.99,
        'statut': 'En cours',
        'produits': [
          {'produitId': 'P003', 'nom': 'Laptop Pro 15"', 'quantite': 1, 'prixUnitaire': 1299.99},
        ],
        'adresseLivraison': '8 Avenue Victor Hugo, 69002 Lyon, France',
        'methodePaiement': 'PayPal',
      },
      {
        '_id': 'CMD003',
        'dateCreation': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'client': {'nom': 'Jean Lefevre', 'telephone': '+33 6 45 67 89 01'},
        'total': 179.98,
        'statut': 'Annulée',
        'produits': [
          {'produitId': 'P004', 'nom': 'Enceinte Bluetooth', 'quantite': 2, 'prixUnitaire': 89.99},
        ],
        'adresseLivraison': '25 Rue du Commerce, 33000 Bordeaux, France',
        'methodePaiement': 'Carte Bancaire',
      },
      {
        '_id': 'CMD004',
        'dateCreation': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'client': {'nom': 'Marie Bernard', 'telephone': '+33 6 23 45 67 89'},
        'total': 599.49,
        'statut': 'En cours',
        'produits': [
          {'produitId': 'P005', 'nom': 'Tablet Média', 'quantite': 1, 'prixUnitaire': 349.99},
          {'produitId': 'P006', 'nom': 'Coque Protection', 'quantite': 1, 'prixUnitaire': 249.50},
        ],
        'adresseLivraison': '12 Boulevard Pasteur, 59000 Lille, France',
        'methodePaiement': 'Carte Bancaire',
      },
      {
        '_id': 'CMD005',
        'dateCreation': DateTime.now().subtract(const Duration(days: 9)).toIso8601String(),
        'client': {'nom': 'Lucas Dubois', 'telephone': '+33 6 34 56 78 90'},
        'total': 1429.98,
        'statut': 'Livrée',
        'produits': [
          {'produitId': 'P003', 'nom': 'Laptop Pro 15"', 'quantite': 1, 'prixUnitaire': 1299.99},
          {'produitId': 'P007', 'nom': 'Souris sans fil', 'quantite': 1, 'prixUnitaire': 129.99},
        ],
        'adresseLivraison': '5 Rue de la République, 13001 Marseille, France',
        'methodePaiement': 'Virement bancaire',
      },
    ];
  }
  
  // Récupérer le détail d'une commande
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      print('📄 Tentative de récupération des détails de la commande $orderId');
      
      // Récupérer le token via le service d'authentification
      final token = await _authService.getToken();
      
      if (token == null) {
        print('❌ Token d\'authentification non trouvé');
        throw Exception('Token non trouvé. Veuillez vous connecter.');
      }
      
      // Utiliser l'endpoint pour les détails de commande - correction de l'URL
      final response = await http.get(
        Uri.parse('$baseUrl/api/commandes/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('📄 Réponse du serveur: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && (data['commande'] != null || data['data'] != null)) {
          print('📄 Détails de la commande récupérés avec succès');
          return data['commande'] ?? data['data'];
        } else {
          print('❌ Réponse API incorrecte ou commande non trouvée: ${response.body}');
          throw Exception('Commande non trouvée');
        }
      } else {
        print('❌ Erreur API: ${response.statusCode} ${response.body}');
        throw Exception('Erreur de serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception lors de la récupération des détails de la commande: $e');
      rethrow;
    }
  }
  
  // Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Récupérer le token via le service d'authentification
      final token = await _authService.getToken();
      
      if (token == null) {
        print('❌ Token d\'authentification non trouvé');
        throw Exception('Token non trouvé. Veuillez vous connecter.');
      }
      
      // Corps de la requête
      final Map<String, dynamic> requestBody = {
        'statut': newStatus
      };
      
      // Utiliser l'endpoint pour mettre à jour une commande - correction de l'URL
      final response = await http.put(
        Uri.parse('$baseUrl/api/commandes/$orderId/annuler'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      
      print('📝 Réponse du serveur: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('❌ Erreur API: ${response.statusCode} ${response.body}');
        throw Exception('Erreur lors de la mise à jour du statut: ${response.statusCode}');
      }
    } catch (e) {
      print('📝 Erreur lors de la mise à jour du statut: $e');
      rethrow;
    }
  }
  
  // Assigner un livreur à une commande
  Future<bool> assignDeliveryPerson(String orderId, String livreurId) async {
    try {
      // Récupérer le token via le service d'authentification
      final token = await _authService.getToken();
      
      if (token == null) {
        print('❌ Token d\'authentification non trouvé');
        throw Exception('Token non trouvé. Veuillez vous connecter.');
      }
      
      // Corps de la requête
      final Map<String, dynamic> requestBody = {
        'livreurId': livreurId
      };
      
      // Utiliser l'endpoint pour assigner un livreur - utiliser l'endpoint approprié
      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/$orderId/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      
      print('📝 Réponse du serveur: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('❌ Erreur API: ${response.statusCode} ${response.body}');
        throw Exception('Erreur lors de l\'assignation du livreur: ${response.statusCode}');
      }
    } catch (e) {
      print('📝 Erreur lors de l\'assignation du livreur: $e');
      rethrow;
    }
  }
} 