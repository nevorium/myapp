import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/main_screen.dart'; // Fixed: Import the new MainScreen
import 'package:provider/provider.dart';

/// # Authentication Wrapper
/// This widget acts as a gatekeeper, directing users to the correct screen
/// based on their authentication status.
///
/// ## Responsibilities:
/// - Listens to the `User` object provided by the `StreamProvider` in `main.dart`.
///
/// ## Connections:
/// - **`main.dart`**: This widget consumes the `User` stream provided at the root.
/// - **`LoginScreen`**: Navigates to this screen if the user is `null` (logged out).
/// - **`MainScreen`**: Navigates to this screen if a `User` object exists (logged in).

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the User stream from the provider.
    final user = context.watch<User?>();

    // If the user object is null, the user is not logged in.
    if (user == null) {
      return const LoginScreen();
    }
    
    // If the user object exists, the user is logged in.
    // We provide the user object down to the MainScreen.
    return Provider<User>.value(
      value: user,
      child: const MainScreen(), // Fixed: Use MainScreen instead of HomeScreen
    );
  }
}
