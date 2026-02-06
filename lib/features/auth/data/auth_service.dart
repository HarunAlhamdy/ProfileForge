import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth wrapper for login, signup, logout.
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    return cred.user;
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    return cred.user;
  }

  Future<void> signOut() => _auth.signOut();
}
