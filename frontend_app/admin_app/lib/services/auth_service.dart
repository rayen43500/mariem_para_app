import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api'; // Remplacez par votre URL
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        print('Réponse du serveur: ${response.body}');
        
        // Vérifier si l'utilisateur est un admin
        if (data['user']['role'] != 'Admin') {
          throw Exception('Accès non autorisé. Seuls les administrateurs peuvent se connecter.');
        }

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
        throw Exception('Erreur de connexion au serveur. Veuillez vérifier votre connexion internet.');
      }
      if (e is FormatException) {
        throw Exception('Erreur de format de réponse du serveur.');
      }
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion');
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'token');
      final userStr = await _storage.read(key: 'user');
      
      if (token == null || userStr == null) return false;
      
      final user = jsonDecode(userStr);
      return user['role'] == 'Admin';
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userStr = await _storage.read(key: 'user');
      if (userStr != null) {
        return jsonDecode(userStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: 'refreshToken');
    } catch (e) {
      return null;
    }
  }
} 