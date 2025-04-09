import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api'; // Remplacez par votre URL
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'motDePasse': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier si l'utilisateur est un admin
        if (data['user']['role'] != 'admin') {
          throw Exception('Accès non autorisé. Seuls les administrateurs peuvent se connecter.');
        }

        // Stocker les tokens
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        await _storage.write(key: 'user', value: jsonEncode(data['user']));

        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userStr = await _storage.read(key: 'user');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }
} 