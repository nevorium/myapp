import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

/// # Firestore Service
/// This class handles all interactions with the Cloud Firestore database.
///
/// ## Responsibilities:
/// - Interacts with the `FirebaseFirestore` instance.
/// - Provides methods to create, read, update, and delete data.
/// - Specifically, it handles creating a user profile document upon registration.
///
/// ## Connections:
/// - **Cloud Firestore**: Depends on the `cloud_firestore` package.
/// - **`AuthService`**: It is often used after a successful authentication event, like registration.
/// - **`RegisterScreen`**: Calls `createUserProfile` after a new user is created in FirebaseAuth.

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ## Create User Profile
  /// Creates a new document in the 'users' collection when a user registers.
  ///
  /// This stores essential user information that is separate from the
  /// authentication record.
  ///
  /// - **`user`**: The `User` object obtained from `FirebaseAuth` after successful registration.
  Future<void> createUserProfile(User user) async {
    try {
      // Create a document with the user's UID as the document ID.
      await _db.collection('users').doc(user.uid).set({
        'profile': {
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(), // Use server time for consistency
        },
        // Initialize other collections/documents as needed.
        'settings': {
          'darkMode': false, // Default setting
          'notifEnabled': true, // Default setting
        }
      });
    } catch (e, s) {
      // If there's an error, log it for debugging.
      developer.log(
        'Error creating user profile',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      // Rethrow the error to be handled by the UI layer.
      rethrow;
    }
  }
  
  // Other Firestore methods (add, update, delete murojaah records) will be added here later.
}
