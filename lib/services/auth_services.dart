import 'package:firebase_auth/firebase_auth.dart';
import 'package:fair_share_app/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirestoreService _firestoreService = FirestoreService();

  Future<UserCredential> signUp({
    required String email,
    required String password,
    String firstName = '',
    String lastName = '',
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    final result = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = result.user;

    if (user != null) {
      await _firestoreService.createUser(
        uid: user.uid,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: cleanEmail,
      );
    }

    return result;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    return await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}

