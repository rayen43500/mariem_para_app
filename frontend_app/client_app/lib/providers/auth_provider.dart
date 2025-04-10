import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      final token = await _storage.read(key: 'token');
      final userStr = await _storage.read(key: 'user');
      
      if (token != null && userStr != null) {
        _token = token;
        _user = json.decode(userStr);
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Error loading auth state: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      
      _token = response['token'];
      _user = response['user'];
      _isAuthenticated = true;

      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'user', value: json.encode(_user));

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'user');
      
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      final response = await _authService.register(email, password, name);
      
      _token = response['token'];
      _user = response['user'];
      _isAuthenticated = true;

      await _storage.write(key: 'token', value: _token);
      await _storage.write(key: 'user', value: json.encode(_user));

      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _authService.refreshToken(refreshToken);
      
      _token = response['token'];
      await _storage.write(key: 'token', value: _token);
      
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'refreshToken');
      await _storage.delete(key: 'user');
      
      notifyListeners();
      rethrow;
    }
  }
} 