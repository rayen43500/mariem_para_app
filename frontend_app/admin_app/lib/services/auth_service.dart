import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Tentative de connexion avec: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'motDePasse': password,
        }),
      );

      print('Statut de la réponse: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        print('Réponse du serveur: ${response.body}');
        
        // Vérifier si l'utilisateur est un admin
        if (data['user']['role'] != 'Admin') {
          print('Rôle non autorisé: ${data['user']['role']}');
          throw Exception('Accès non autorisé. Seuls les administrateurs peuvent se connecter.');
        }

        print('Connexion réussie pour: ${data['user']['nom']} (${data['user']['role']})');
        
        // Stocker les tokens et les informations utilisateur
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));

        return {
          'token': data['token'],
          'refreshToken': data['refreshToken'],
          'user': data['user'],
        };
      } else {
        print('Erreur de connexion: ${response.body}');
        final error = jsonDecode(response.body);
        if (error['errors'] != null && error['errors']['motDePasse'] != null) {
          throw Exception(error['errors']['motDePasse']);
        }
        throw Exception(error['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      print('Exception lors de la connexion: $e');
      if (e is http.ClientException) {
        throw Exception('Erreur de connexion au serveur. Veuillez vérifier votre connexion internet et l\'URL du serveur.');
      }
      if (e is FormatException) {
        throw Exception('Erreur de format de réponse du serveur. Vérifiez que le serveur fonctionne correctement.');
      }
      // Renvoi de l'exception originale si elle est déjà bien formatée
      if (e.toString().startsWith('Exception: ')) {
        throw e;
      }
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      print('Déconnexion de l\'utilisateur');
      await _storage.deleteAll();
      print('Stockage effacé avec succès');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw Exception('Erreur lors de la déconnexion');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'token');
      final userStr = await _storage.read(key: 'user');
      
      if (token == null || userStr == null) {
        print('Aucun token ou utilisateur trouvé dans le stockage');
        return false;
      }
      
      final user = jsonDecode(userStr);
      final isAdmin = user['role'] == 'Admin';
      
      print('Vérification de connexion: ${isAdmin ? 'Administrateur connecté' : 'Utilisateur non-admin'}');
      
      return isAdmin;
    } catch (e) {
      print('Erreur lors de la vérification de connexion: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userStr = await _storage.read(key: 'user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        print('Utilisateur actuel récupéré: ${user['nom']} (${user['role']})');
        return user;
      }
      print('Aucun utilisateur trouvé dans le stockage');
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'token');
      return token;
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      return refreshToken;
    } catch (e) {
      print('Erreur lors de la récupération du refresh token: $e');
      return null;
    }
  }
  
  // Méthode pour vérifier si le token est valide
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      // Vous pouvez ajouter une requête au backend pour valider le token si nécessaire
      // Par exemple:
      /*
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify-token'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
      */
      
      // Pour l'instant, nous considérons un token comme valide s'il existe
      return true;
    } catch (e) {
      print('Erreur lors de la validation du token: $e');
      return false;
    }
  }

  // Méthode pour tester la connexion avec un appel API authentifié
  Future<bool> testAuthenticatedRequest() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('Pas de token disponible pour la requête authentifiée');
        return false;
      }
      
      print('Test de requête authentifiée avec token');
      
      // Faire une requête authentifiée à une API qui nécessite des droits admin
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'), // Exemple d'API réservée aux admins
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      print('Réponse du test d\'authentification: ${response.statusCode}');
      
      // Si la réponse est 200, l'authentification fonctionne correctement
      // Si la réponse est 401 ou 403, il y a un problème d'authentification
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors du test d\'authentification: $e');
      return false;
    }
  }
} 