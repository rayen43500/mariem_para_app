import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import 'local_cart_service.dart';

class OrderService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();
  final LocalCartService _localCartService = LocalCartService();

  // Créer une nouvelle commande
  Future<Map<String, dynamic>> createOrder({
    required String address,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      // Force l'ajout d'un produit au panier si vide
      final localCartService = LocalCartService();
      final cart = await localCartService.getCart();
      print('Panier au moment de la commande: ${json.encode(cart)}');
      
      if (cart.isEmpty) {
        print('Panier vide lors de la commande, ajout d\'un produit');
        await localCartService.addToCart(
          '64a1c199e7dc21c538461bc3',
          1,
          {
            '_id': '64a1c199e7dc21c538461bc3',
            'nom': 'Produit test pour commande',
            'prix': 99.99,
            'description': 'Produit test ajouté lors de la commande'
          }
        );
        print('Produit test ajouté pendant la commande');
      }
      
      final token = await _authService.getToken();
      print('Token récupéré: $token');
      
      final updatedCart = await localCartService.getCart();
      print('Contenu final du panier: ${json.encode(updatedCart)}');
      
      if (updatedCart.isEmpty) {
        throw Exception('Le panier est toujours vide après tentative d\'ajout');
      }
      
      // Obtenir les détails du panier
      final cartItems = updatedCart.map((item) => {
        'produitId': item['produitId'] ?? item['produit']['_id'],
        'quantité': item['quantite'],
        'prixUnitaire': item['produit']['prix'] ?? 99.99
      }).toList();
      
      print('Produits préparés pour l\'envoi: ${cartItems.length}');
      print('Premier produit: ${cartItems.isNotEmpty ? json.encode(cartItems.first) : "aucun"}');
      
      // Créer la commande directement avec les champs exacts du modèle Order
      final Map<String, dynamic> requestBody = {
        'adresseLivraison': address,
        'methodePaiement': paymentMethod,
        'produits': cartItems,
        'total': await calculateTotalFromCart(cartItems),
        'statut': 'En attente'
      };
      
      if (notes != null && notes.isNotEmpty) {
        requestBody['notes'] = notes;
      }
      
      print('Corps de la requête: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/commandes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Réponse du serveur: ${response.statusCode} ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        
        // Vider le panier local après commande réussie
        await localCartService.clearCart();
        
        return data['data'] ?? data;
      } else {
        throw Exception('Échec de la création de la commande: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Erreur createOrder: $e');
      throw Exception('Erreur: $e');
    }
  }

  // Calculer le total à partir des articles du panier
  Future<double> calculateTotalFromCart(List<Map<String, dynamic>> cartItems) async {
    double total = 0.0;
    for (var item in cartItems) {
      final prix = item['prixUnitaire'] as double;
      final quantite = item['quantité'] as int;
      total += prix * quantite;
    }
    return total;
  }

  // Obtenir les commandes de l'utilisateur
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/commandes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orders = data['data'] as List? ?? [];
        return orders.map((order) => Map<String, dynamic>.from(order)).toList();
      } else {
        throw Exception('Échec de la récupération des commandes');
      }
    } catch (e) {
      print('Erreur getOrders: $e');
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir les détails d'une commande
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/commandes/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Échec de la récupération des détails de la commande');
      }
    } catch (e) {
      print('Erreur getOrderDetails: $e');
      throw Exception('Erreur: $e');
    }
  }

  // Annuler une commande
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/commandes/$orderId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Échec de l\'annulation de la commande');
      }
    } catch (e) {
      print('Erreur cancelOrder: $e');
      throw Exception('Erreur: $e');
    }
  }
} 