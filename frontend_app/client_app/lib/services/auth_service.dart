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
    try {
      // Tenter de récupérer les informations utilisateur depuis le stockage local
      final userStr = await _storage.read(key: 'user');
      
      if (userStr != null) {
        final userData = json.decode(userStr);
        print('Informations utilisateur récupérées depuis le stockage local: ${userData['_id']}');
        return userData;
      }
      
      // Si pas d'infos utilisateur stockées, essayer de récupérer depuis le token
      print('Infos utilisateur non trouvées dans le stockage, tentative via token...');
      final token = await getToken();
      
      if (token != null) {
        try {
          // Récupérer les informations utilisateur à partir du token JWT
          final parts = token.split('.');
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
          );
          
          // Vérifier si le payload contient des informations utilisateur
          if (payload.containsKey('userId')) {
            // Récupérer les informations complètes de l'utilisateur
            return await getUserInfoFromAPI(payload['userId']);
          }
        } catch (e) {
          print('Erreur lors de la récupération des infos depuis le token: $e');
        }
      }
      
      return null;
    } catch (e) {
      print('Erreur getCurrentUser: $e');
      return null;
    }
  }
  
  // Récupérer les informations de l'utilisateur depuis l'API
  Future<Map<String, dynamic>?> getUserInfoFromAPI(String userId) async {
    try {
      print('Tentative de récupération des informations utilisateur depuis l\'API...');
      final token = await getToken();
      
      if (token == null) {
        return null;
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'] ?? data;
        
        // Stocker les informations récupérées
        await _storage.write(key: 'user', value: json.encode(user));
        print('Informations utilisateur mises à jour depuis l\'API');
        
        return user;
      } else {
        print('Erreur lors de la récupération des infos utilisateur: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la récupération des infos utilisateur: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'token');
      print('Token récupéré: ${token != null ? token.substring(0, 10) + "..." : "null"}');
      
      if (token == null) {
        print('Aucun token trouvé dans le stockage');
        return null;
      }
      
      // Vérifier si le token a un format valide (structure JWT basique)
      if (!token.contains('.') || token.split('.').length != 3) {
        print('Format de token invalide: ${token.substring(0, 10)}...');
        // Supprimer le token invalide
        await _storage.delete(key: 'token');
        return null;
      }
      
      // Vérifier si le token est expiré
      try {
        final parts = token.split('.');
        final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
        );
        
        if (payload.containsKey('exp')) {
          final exp = payload['exp'];
          final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          final now = DateTime.now();
          
          if (now.isAfter(expDate)) {
            print('Token expiré à ${expDate.toIso8601String()}');
            
            // Essayer de rafraîchir le token
            final refreshTokenValue = await getRefreshToken();
            if (refreshTokenValue != null) {
              try {
                final newTokenData = await this.refreshToken(refreshTokenValue);
                final newToken = newTokenData['token'];
                await _storage.write(key: 'token', value: newToken);
                print('Token rafraîchi avec succès');
                return newToken;
              } catch (e) {
                print('Échec du rafraîchissement du token: $e');
                await logout();
                return null;
              }
            } else {
              await logout();
              return null;
            }
          }
        }
      } catch (e) {
        print('Erreur lors de la validation du token: $e');
        // En cas d'erreur de parsing, on conserve le token tel quel
        // pour que le backend puisse le rejeter si nécessaire
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