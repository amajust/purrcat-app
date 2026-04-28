import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

// Models
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  firebase_auth.FirebaseAuth get firebaseAuth => _firebaseAuth;

  AuthProvider() {
    // Listen to Firebase Auth state changes
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(firebase_auth.User? fbUser) {
    if (fbUser != null) {
      _currentUser = User(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        name: fbUser.displayName ?? 'User',
        avatarUrl: fbUser.photoURL,
        phone: fbUser.phoneNumber,
      );
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Check if user is already logged in on app start
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null) {
        _currentUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ?? 'User',
          avatarUrl: fbUser.photoURL,
          phone: fbUser.phoneNumber,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password via Firebase
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbUser = userCredential.user;
      if (fbUser != null) {
        _currentUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ?? 'User',
          avatarUrl: fbUser.photoURL,
          phone: fbUser.phoneNumber,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Get Google authentication credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final fbUser = userCredential.user;
      if (fbUser != null) {
        _currentUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          name: fbUser.displayName ?? googleUser.displayName ?? 'User',
          avatarUrl: fbUser.photoURL ?? googleUser.photoUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register new user with email/password
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      final fbUser = _firebaseAuth.currentUser;
      if (fbUser != null) {
        _currentUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          name: name,
          phone: phone,
          avatarUrl: fbUser.photoURL,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout from Firebase
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Map Firebase Auth error codes to user-friendly messages in Indonesian
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password minimal 6 karakter';
      case 'operation-not-allowed':
        return 'Login metode ini belum diaktifkan';
      case 'account-exists-with-different-credential':
        return 'Email sudah terdaftar dengan metode login lain';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      default:
        return 'Terjadi kesalahan: $code';
    }
  }
}
