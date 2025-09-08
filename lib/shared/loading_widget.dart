import 'package:flutter/material.dart';

/// # Loading Widget
/// A simple, reusable widget to display a centered loading indicator.
///
/// ## Responsibilities:
/// - Provides a consistent loading animation for the entire app.
/// - Encapsulates the `CircularProgressIndicator` within a `Scaffold` and `Center` widget for easy use.
///
/// ## Connections:
/// - Used by any screen or widget that needs to show a loading state while waiting for an asynchronous operation to complete (e.g., `AuthWrapper`, `LoginScreen`).

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color to match the theme's background.
      backgroundColor: Theme.of(context).colorScheme.surface, // FIX: Used surface instead of deprecated background
      body: Center(
        // The CircularProgressIndicator provides a spinning animation.
        child: CircularProgressIndicator(
          // Optionally, set the color to match the theme's primary color.
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
