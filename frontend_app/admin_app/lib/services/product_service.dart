import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ProductService {
  final AuthService _authService = AuthService();
  final String baseUrl = ApiConfig.baseUrl;
  final _logger = Logger();

  // Récupérer tous les produits
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? category,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    bool? onSale
  }) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      // Construction des paramètres de requête
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null && category != 'Toutes') queryParams['category'] = category;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (inStock != null) queryParams['inStock'] = inStock.toString();
      if (onSale != null) queryParams['onSale'] = onSale.toString();

      final Uri uri = Uri.parse('$baseUrl/api/produits').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de récupération des produits: ${response.body}');
      }
    } catch (e) {
      _logger.e('Erreur dans getProducts: $e');
      rethrow;
    }
  }

  // Récupérer un produit par son ID
  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/produits/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de récupération du produit: ${response.body}');
      }
    } catch (e) {
      _logger.e('Erreur dans getProductById: $e');
      rethrow;
    }
  }

  // Créer un nouveau produit
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/produits'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productData),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de création du produit: ${response.body}');
      }
    } catch (e) {
      _logger.e('Erreur dans createProduct: $e');
      rethrow;
    }
  }

  // Mettre à jour un produit
  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> productData) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/produits/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(productData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de mise à jour du produit: ${response.body}');
      }
    } catch (e) {
      _logger.e('Erreur dans updateProduct: $e');
      rethrow;
    }
  }

  // Rechercher des produits
  Future<List<dynamic>> searchProducts(String query, {int limit = 10}) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/produits/search?q=$query&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de recherche des produits: ${response.body}');
      }
    } catch (e) {
      _logger.e('Erreur dans searchProducts: $e');
      rethrow;
    }
  }

  // Réapprovisionner le stock d'un produit
  Future<Map<String, dynamic>> restockProduct(String id, int quantity, {String? reference, String? commentaire}) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/produits/$id/restock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'quantity': quantity,
          'référence': reference,
          'commentaire': commentaire,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de réapprovisionnement du produit: ${response.body}');
      }
    } catch (e) {
      _logger.e('Erreur dans restockProduct: $e');
      rethrow;
    }
  }

  // Obtenir les produits en rupture de stock ou en stock faible
  Future<Map<String, dynamic>> getLowStockProducts({int threshold = 5}) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/produits/inventory/low-stock?threshold=$threshold'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec de récupération des produits en stock faible: ${response.body}');
      }
    } catch (e) {
      _logger.e('Erreur dans getLowStockProducts: $e');
      rethrow;
    }
  }

  // Ajuster le stock d'un produit
  Future<Map<String, dynamic>> adjustStock(String id, int nouveauStock, {String? commentaire}) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/produits/$id/adjust-stock'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'nouveauStock': nouveauStock,
          'commentaire': commentaire,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Échec d\'ajustement du stock: ${response.body}');
      }
    } catch (e) {
      _logger.e('Erreur dans adjustStock: $e');
      rethrow;
    }
  }
} 