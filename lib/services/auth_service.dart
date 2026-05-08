import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        return AuthResult(success: true, user: result.user);
      }

      return AuthResult(success: false, error: 'Login failed');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      return AuthResult(success: false, error: message);
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Network error. Please check your connection.',
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

class AuthResult {
  final bool success;
  final User? user;
  final String? error;

  AuthResult({required this.success, this.user, this.error});
}
