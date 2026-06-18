import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String _userName = 'User Account';
  String get userName => _userName;

  Future<void> loadUser() async {
    String? name = await _apiService.getName();
    if (name != null) {
      _userName = name;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    bool success = await _apiService.login(email, password);
    if (success) {
      _isAuthenticated = true;
      await loadUser();
    }
    return success;
  }

  Future<bool> register(String name, String email, String password) async {
    return await _apiService.register(name, email, password);
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
