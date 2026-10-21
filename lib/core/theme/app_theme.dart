import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// App theme configuration for light and dark modes
class AppTheme {
  AppTheme._();

  // Base colors
  static const Color _ink = Color(0xFF111111);
  static const Color _muted = Color(0xFF777777);
  static const Color _backgroundLight = Color(0xFFF5F5F3);
  static const Color _backgroundDark = Color(0xFF1A1A1A);

  /// Light theme using Uganda color palette
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.ugandaGreen,
        brightness: Brightness.light,
        primary: AppConstants.ugandaGreen,
        secondary: AppConstants.ugandaYellow,
        error: AppConstants.ugandaRed,
        surface: Colors.white,
        background: _backgroundLight,
      ),

      // Text theme
      textTheme: _buildTextTheme(Brightness.light),

      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _backgroundLight,
        foregroundColor: _ink,
        titleTextStyle: const TextStyle(
          color: _ink,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppConstants.ugandaGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Filled button theme (for primary actions)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppConstants.ugandaGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.ugandaGreen,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.ugandaGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.ugandaRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.ugandaRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: _ink,
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _ink,
        unselectedItemColor: _muted,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8E8E6),
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark theme using Uganda color palette
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.ugandaGreen,
        brightness: Brightness.dark,
        primary: AppConstants.ugandaGreen,
        secondary: AppConstants.ugandaYellow,
        error: AppConstants.ugandaRed,
        surface: const Color(0xFF2A2A2A),
        background: _backgroundDark,
      ),

      // Text theme
      textTheme: _buildTextTheme(Brightness.dark),

      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _backgroundDark,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppConstants.ugandaGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: AppConstants.ugandaGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.ugandaGreen,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppConstants.ugandaGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.ugandaRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.ugandaRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: Colors.white,
        side: const BorderSide(color: Color(0xFF444444)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2A2A2A),
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFF888888),
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF333333),
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Build text theme for the specified brightness
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light ? _ink : Colors.white;
    final mutedColor = brightness == Brightness.light
        ? _muted
        : const Color(0xFF888888);

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.8,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.7,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.6,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: mutedColor,
      ),
    );
  }
}
