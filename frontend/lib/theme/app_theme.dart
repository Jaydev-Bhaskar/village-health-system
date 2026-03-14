import 'package:flutter/material.dart';

/// Village Health Monitoring System — Design System Theme
/// Based on Medical Trust Blue (#1976D2) primary palette.
class AppTheme {
  // ── Color Palette ─────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color deepNavy = Color(0xFF0D47A1);
  static const Color lightBlueTint = Color(0xFFE3F2FD);
  static const Color clinicalWhite = Color(0xFFFFFFFF);
  static const Color softGrey = Color(0xFFF5F5F5);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color charcoalText = Color(0xFF212121);
  static const Color mutedGrey = Color(0xFF757575);
  static const Color normalGreen = Color(0xFF4CAF50);
  static const Color cautionAmber = Color(0xFFFFC107);
  static const Color alertRed = Color(0xFFF44336);

  // ── Risk Colors ───────────────────────────────────────────────────────────
  static Color riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return alertRed;
      case 'moderate':
        return cautionAmber;
      case 'normal':
      case 'low':
        return normalGreen;
      default:
        return mutedGrey;
    }
  }

  // ── Theme Data ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        surface: clinicalWhite,
        error: alertRed,
      ),
      scaffoldBackgroundColor: clinicalWhite,
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: clinicalWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: clinicalWhite,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: softGrey,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      // Elevated Buttons (Primary)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: clinicalWhite,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Outlined Buttons (Secondary)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: mutedGrey, fontSize: 14),
        hintStyle: const TextStyle(color: mutedGrey, fontSize: 14),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: clinicalWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mutedGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: softGrey,
        selectedColor: lightBlueTint,
        labelStyle: const TextStyle(fontSize: 14, color: charcoalText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderGrey),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: borderGrey,
        thickness: 1,
      ),
    );
  }
}
