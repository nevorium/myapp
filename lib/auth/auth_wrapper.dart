import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/main_screen.dart'; // Import the new MainScreen
import 'package:provider/provider.dart';

/// # Auth Wrapper
/// This widget acts as a gatekeeper for the application.
/// It listens to the authentication state changes from Firebase and determines
/// whether to show the `LoginScreen` or the `MainScreen`.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the user from the Provider.
    final user = Provider.of<User?>(context);

    // Check if the user is logged in and return the appropriate screen.
    if (user == null) {
      // If the user is not logged in, show the LoginScreen.
      return const LoginScreen();
    } else {
      // If the user is logged in, show the MainScreen.
      // This is the entry point to the main part of the app.
      return const MainScreen();
    }
  }
}
