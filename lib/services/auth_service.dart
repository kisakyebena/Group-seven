import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        await _updateLastLogin(result.user!.uid);
        final appUser = await _getAppUser(result.user!.uid);
        return AuthResult(success: true, user: result.user, appUser: appUser);
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

  Future<AuthResult> registerStaff({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        final appUser = AppUser(
          id: result.user!.uid,
          email: email.trim(),
          name: name,
          role: UserRole.staff,
        );
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(appUser.toFirestore());

        return AuthResult(success: true, user: result.user, appUser: appUser);
      }

      return AuthResult(success: false, error: 'Registration failed');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'weak-password':
          message = 'Password should be at least 6 characters';
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

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<AppUser?> _getAppUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<AppUser?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    });
  }
}

class AuthResult {
  final bool success;
  final User? user;
  final AppUser? appUser;
  final String? error;

  AuthResult({required this.success, this.user, this.appUser, this.error});
}
