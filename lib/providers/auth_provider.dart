import 'package:fair_share_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? user;
  bool isLoading = false;
  String? errorMessage;

  String _friendlyError(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
    }
  }
    return 'Something went wrong. Please try again.';
  }

  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
    final result = await _authService.signUp(
    email: email,
    password: password,
    firstName: firstName,
    lastName: lastName,
    );
    user = result.user;
    if (user == null) errorMessage = 'Unable to create account.';
    }   catch (e) {
    errorMessage = _friendlyError(e);
    user = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      user = result.user;
    } catch (e) {
      errorMessage = _friendlyError(e);
      user = null;
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
