import 'package:fair_share_app/services/auth_services.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? user;
  bool isLoading = false;
  String? errorMessage;

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
      );

      final newUser = result.user;

      if (newUser == null) {
        errorMessage = 'Unable to create account.';
        isLoading = false;
        notifyListeners();
        return;
      }

      await _firestoreService.createUser(
        uid: newUser.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      user = newUser;
    } catch (e) {
      errorMessage = e.toString();
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
      errorMessage = e.toString();
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
