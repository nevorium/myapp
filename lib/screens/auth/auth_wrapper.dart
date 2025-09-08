import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/shared/loading_widget.dart';

/// # Authentication Wrapper
/// This widget acts as a gatekeeper, directing users to the correct screen
/// based on their authentication status.
///
/// ## Responsibilities:
/// - Listens to Firebase's `authStateChanges()` stream to detect when a user logs in or out.
/// - The stream provides a `User` object if the user is authenticated, or `null` otherwise.
///
/// ## Connections:
/// - **Firebase Auth**: Directly connects to the `firebase_auth` package to get the auth state.
/// - **`main.dart`**: This widget is set as the `home` of the `MaterialApp`, making it the first UI screen loaded.
/// - **`LoginScreen`**: Navigates to this screen if the user is not authenticated.
/// - **`HomeScreen`**: Navigates to this screen if the user is authenticated.
/// - **`LoadingWidget`**: Shows a loading indicator while the connection to Firebase is being established.

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to the authentication state changes.
    return StreamBuilder<User?>(
      // The stream from FirebaseAuth that notifies about user login/logout.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // --- Case 1: Waiting for connection ---
        // If the snapshot is still waiting for data, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        }

        // --- Case 2: User is logged in ---
        // If the snapshot has data, it means the user is authenticated.
        if (snapshot.hasData) {
          // Navigate to the main content of the app.
          return const HomeScreen();
        }

        // --- Case 3: User is logged out ---
        // If the snapshot has no data, the user is not authenticated.
        else {
          // Navigate to the login screen.
          return const LoginScreen();
        }
      },
    );
  }
}
