import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldAccent = Color(
    0xFFFFD700,
  ); // Lighter gold for gradients
  static const Color surfaceDark = Color(
    0xFF1E293B,
  ); // Slightly lighter than bg

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldPrimary, goldAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AD4AF37), // Gold with low opacity
      Color(0x0DD4AF37),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get luxuryTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: goldPrimary,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: goldAccent,
        surface: darkBackground,
        background: darkBackground,
        onPrimary: Colors.black, // Text on Gold
        onSurface: textPrimary,
      ),

      // Text Theme
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textPrimary, displayColor: goldPrimary),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lato(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldPrimary),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Slightly boxy luxury feel
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
