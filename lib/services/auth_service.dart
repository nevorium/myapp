import 'package:firebase_auth/firebase_auth.dart';

/// # Authentication Service
/// This class handles all the business logic related to Firebase Authentication.
///
/// ## Responsibilities:
/// - Interacts with the `FirebaseAuth` instance.
/// - Provides methods for user registration (`signUpWithEmail`), sign-in (`signInWithEmail`), and sign-out (`signOut`).
/// - Implements robust error handling for common authentication issues (e.g., email-already-in-use, weak-password, user-not-found).
///
/// ## Connections:
/// - **Firebase Auth**: Depends on the `firebase_auth` package to communicate with the authentication backend.
/// - **`LoginScreen` / `RegisterScreen`**: The UI widgets will call methods from this service to perform auth operations.
/// - **Error Handling**: Provides user-friendly error messages to be displayed on the UI (e.g., in a SnackBar).

class AuthService {
  // Get an instance of FirebaseAuth.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // --- Stream to listen for auth state changes ---
  // This can be used by other parts of the app to react to login/logout events.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- Get Current User ---
  User? get currentUser => _firebaseAuth.currentUser; // FIX: Corrected typo from _firebase_auth


  /// ## Sign Up with Email and Password
  /// Attempts to create a new user account with the provided email and password.
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If successful, return null (no error).
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors.
      if (e.code == 'weak-password') {
        return 'Password yang dimasukkan terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Akun sudah terdaftar untuk email ini.';
      } else {
        return 'Terjadi kesalahan. Silakan coba lagi.';
      }
    } catch (e) {
      // Handle any other unexpected errors.
      return 'Terjadi kesalahan yang tidak diketahui.';
    }
  }

  /// ## Sign In with Email and Password
  /// Attempts to sign in an existing user with their email and password.
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If successful, return null (no error).
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication errors.
      if (e.code == 'user-not-found') {
        return 'Tidak ada pengguna yang terdaftar dengan email ini.';
      } else if (e.code == 'wrong-password') {
        return 'Password yang dimasukkan salah.';
      } else {
        return 'Terjadi kesalahan. Pastikan email dan password benar.';
      }
    } catch (e) {
      // Handle any other unexpected errors.
      return 'Terjadi kesalahan yang tidak diketahui.';
    }
  }

  /// ## Sign Out
  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
