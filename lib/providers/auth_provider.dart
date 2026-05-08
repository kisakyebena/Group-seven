import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  AppUser? _appUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  UserRole? get userRole => _appUser?.role;
  bool get isAdmin => _appUser?.role == UserRole.admin;
  bool get isStaff => _appUser?.role == UserRole.staff;
  String? get userEmail => _currentUser?.email;
  String? get userName => _currentUser?.displayName ?? _appUser?.name;

  AuthProvider() {
    _currentUser = _authService.getCurrentUser();
    _isAuthenticated = _currentUser != null;
    if (_currentUser != null) {
      _loadAppUser(_currentUser!.uid);
    }
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      _isAuthenticated = user != null;
      if (user != null) {
        _loadAppUser(user.uid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadAppUser(String uid) async {
    final userStream = _authService.getUserStream(uid);
    userStream.listen((AppUser? appUser) {
      _appUser = appUser;
      notifyListeners();
    });
    final appUser = await _authService.getUserStream(uid).first;
    _appUser = appUser;
    notifyListeners();
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
      _appUser = result.appUser;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerStaff({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.registerStaff(
      email: email,
      password: password,
      name: name,
    );

    _isLoading = false;

    if (result.success) {
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
    _appUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
