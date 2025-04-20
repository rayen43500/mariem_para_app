import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class OrderService {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Créer une nouvelle commande
  Future<Map<String, dynamic>> createOrder({
    required String address,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'adresse': address,
          'methodePaiement': paymentMethod,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Échec de la création de la commande: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Erreur createOrder: $e');
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir les commandes de l'utilisateur
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orders = data['data'] as List;
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
        Uri.parse('$baseUrl/orders/$orderId'),
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
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
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