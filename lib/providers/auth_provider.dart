import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../core/constants.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  User? _user;
  bool _isLoading = false;
  String? _token;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        _token = response['data']['token'];
        _user = User.fromJson(response['data']['user']);
        
        await _storage.write(key: 'auth_token', value: _token);
        // Save user details if needed, or fetch profile later
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Register
  Future<bool> register(String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post(ApiConstants.register, {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });
      // Registration successful, usually redirect to login or auto-login
      // For now, return true
      _isLoading = false;
      notifyListeners();
      return response['success'] == true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }

  // Check Auth Status (Run on App Start)
  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      _token = token;
      // Ideally fetch profile here to populate _user
      try {
         final response = await _apiService.get(ApiConstants.profile);
         if (response['success'] == true) {
           _user = User.fromJson(response['data']);
         }
      } catch (_) {
        // Token might be invalid
        logout();
      }
    }
    notifyListeners();
  }
}
