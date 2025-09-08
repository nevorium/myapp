import 'package:flutter/material.dart';
import 'package:myapp/services/auth_service.dart';

/// # Home Screen
/// This is the main screen that authenticated users will see.
///
/// ## Responsibilities:
/// - Acts as the primary container for the application's core features.
/// - Displays a welcome message to the user.
/// - Contains a logout button to allow users to sign out.
/// - Will eventually host the calendar dashboard, daily checklist, and motivational widgets.
///
/// ## Connections:
/// - **`AuthWrapper`**: Navigates here after a successful login.
/// - **`AuthService`**: Uses the `signOut` method to log the user out.
/// - **Other UI Components**: This screen will be the parent for the `TableCalendar`, `Checklist`, etc.

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instance of AuthService to handle logout.
    final authService = AuthService(); // FIX: Removed leading underscore
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Murojaah Tracker'),
        actions: [
          // --- Logout Button ---
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              // Show a confirmation dialog before logging out.
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );

              // If the user confirmed, sign them out.
              if (confirmed ?? false) {
                await authService.signOut();
                // The AuthWrapper will handle navigation to the LoginScreen.
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Display the user's email if available.
            Text(
              user?.email ?? 'Pengguna',
              style: const TextStyle(fontSize: 16),
            ),
             const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Halaman utama ini akan menampilkan kalender progres, checklist harian, dan widget motivasi Anda. Nantikan pembaruan selanjutnya!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
