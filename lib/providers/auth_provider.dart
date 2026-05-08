import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName;

  AuthProvider() {
    _currentUser = _authService.getCurrentUser();
    _isAuthenticated = _currentUser != null;
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result.success) {
      _isAuthenticated = true;
      _currentUser = result.user;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _isAuthenticated = false;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
