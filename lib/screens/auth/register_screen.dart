import 'package:flutter/material.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';

/// # Register Screen
/// This screen provides the UI for new users to create an account.
///
/// ## Responsibilities:
/// - Displays input fields for email, password, and password confirmation.
/// - Contains a "Daftar" (Register) button to trigger the account creation process.
/// - Uses the `AuthService` to create the user and the `FirestoreService` to create their profile.
///
/// ## Connections:
/// - **`LoginScreen`**: Navigates here when a user clicks "Daftar di sini".
/// - **`AuthService`**: Calls the `signUpWithEmail` method.
/// - **`FirestoreService`**: Calls the `createUserProfile` method on success.

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// ## Registration Logic
  /// Handles the user registration process.
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 1. Create the user with email and password.
      final error = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (error == null) {
        // 2. If user creation is successful, create their profile in Firestore.
        final user = _authService.currentUser;
        if (user != null) {
          try {
            await _firestoreService.createUserProfile(user);
            // 3. Show success message and pop back to the login screen.
            if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pendaftaran berhasil! Silakan masuk.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } catch (e) {
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal membuat profil: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } else {
        // If there was an auth error, show it.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Akun Baru'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header ---
                  Icon(
                    Icons.person_add_alt_1,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gabung Bersama Kami',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai perjalanan murojaah Anda hari ini.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 40),

                  // --- Input Fields ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (value) {
                       if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                       if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Format email tidak valid';
                       return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                      if (value.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                       suffixIcon: IconButton(
                        icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) return 'Password tidak cocok';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Text('Daftar'),
                        ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun?'),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Masuk di sini', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
