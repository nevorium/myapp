import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// # Theme Configuration
/// This file centralizes the application's theme settings.
///
/// ## Responsibilities:
/// - Defines the primary color palette using `ColorScheme.fromSeed` for Material 3.
/// - Configures `TextTheme` with the 'Inter' font from Google Fonts for a consistent typography.
/// - Creates distinct `ThemeData` for both light and dark modes, ensuring a consistent user experience.
/// - Customizes themes for specific components like `AppBar` and `ElevatedButton` to match the app's branding.
///
/// ## Connections:
/// - **`main.dart`**: This theme is applied to the `MaterialApp` widget, making it available globally.
/// - **`ThemeProvider`**: The `ThemeProvider` class will use these theme objects to allow users to switch between light and dark modes.

class AppTheme {
  // Define a seed color that will generate the color scheme for the app.
  static const _seedColor = Color(0xFF006D3D); // A deep, calming green

  // --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // Generate a color scheme from the seed color for the light theme.
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      primary: _seedColor,
      secondary: const Color(0xFF4CAF50), // A complementary green
    ),
    // Use Google Fonts to define the text theme for consistency.
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: _seedColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _seedColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _seedColor, width: 2),
      ),
    ),
    cardTheme: CardThemeData( // FIX: Changed CardTheme to CardThemeData
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    ),
  );

  // --- Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    // Generate a color scheme from the seed color for the dark theme.
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF66BB6A), // A lighter green for dark mode contrast
      secondary: const Color(0xFF81C784),
    ),
    // Use Google Fonts for the dark theme as well.
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF66BB6A),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF66BB6A), width: 2),
      ),
    ),
    cardTheme: CardThemeData( // FIX: Changed CardTheme to CardThemeData
      elevation: 4,
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    ),
  );
}

/// # Theme Provider
/// Manages the application's theme state (light/dark mode).
///
/// ## Responsibilities:
/// - Holds the current `ThemeMode`.
/// - Provides a method `toggleTheme` to switch between light and dark modes.
/// - Notifies listeners when the theme changes, causing the UI to rebuild.
///
/// ## Connections:
/// - **`main.dart`**: An instance of this provider is created at the root of the application using `ChangeNotifierProvider`.
/// - **UI Components**: Any widget can access this provider (e.g., via `Provider.of`) to toggle the theme.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to light mode

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify widgets to rebuild
  }
}
