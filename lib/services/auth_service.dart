
import 'package:firebase_auth/firebase_auth.dart';
import 'activity_log_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ActivityLogService _logs = ActivityLogService();

  static const String adminUid =
      'eEoJmkYDSPWTwlK4vm4h7Ayrc6R2';

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  bool get isAdmin => currentUser?.uid == adminUid;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user?.uid != adminUid) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'This account does not have admin access.',
      );
    }

    await _logs.recordSafely(
      action: 'LOGIN',
      description: 'Admin logged in',
    );

    return credential;
  }

  Future<void> signOut() async {
    await _logs.recordSafely(
      action: 'LOGOUT',
      description: 'Admin logged out',
    );

    await _auth.signOut();
  }

  String getErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'permission-denied':
        return 'This account does not have admin access.';
      default:
        return error.message ??
            'Login failed. Please try again.';
    }
  }
}
