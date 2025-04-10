import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'motDePasse': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Vérifier si l'utilisateur est un client
        if (data['user']['role'] != 'Client') {
          throw Exception('Accès non autorisé. Cette application est réservée aux clients.');
        }

        // Sauvegarder le token et les informations utilisateur
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        await _storage.write(key: 'user', value: json.encode(data['user']));

        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'motDePasse': password,
          'nom': name,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Ne pas sauvegarder les tokens et infos utilisateur lors de l'inscription
        // L'utilisateur devra se connecter manuellement
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de l\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refreshToken');
    await _storage.delete(key: 'user');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userStr = await _storage.read(key: 'user');
    if (userStr != null) {
      return json.decode(userStr);
    }
    return null;
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'token');
      print('Token récupéré: ${token ?? "null"}');
      
      if (token == null) {
        print('Aucun token trouvé dans le stockage');
        return null;
      }
      
      // Vérifier si le token a un format valide (structure JWT basique)
      if (!token.contains('.') || token.split('.').length != 3) {
        print('Format de token invalide: $token');
        // Supprimer le token invalide
        await _storage.delete(key: 'token');
        return null;
      }
      
      return token;
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'refreshToken': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }

  Future<bool> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/validate'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 