import 'package:fair_share_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  bool isLoading = false;
  String? errorMessage;

  Future<void> signUp(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
      );

      user = result.user;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      user = result.user;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();

    user = null;
    notifyListeners();
  }
}
