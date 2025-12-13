import 'package:flutter/material.dart';

class AppTheme {
  // 1. Standardize Colors
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryDark = Color(0xFF005691);
  static const Color backgroundGrey = Color(0xFFF5F7FA);
  static const Color textBlack = Color(0xFF2D3436);
  static const Color textGrey = Color(0xFF636E72);
  static const Color successGreen = Color(0xFF00B894);
  static const Color warningAmber = Color(0xFFFDCB6E);
  static const Color errorRed = Color(0xFFD63031);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundGrey,
      
      // 2. Standardize AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textBlack),
        iconTheme: IconThemeData(color: textBlack),
      ),

      // 3. Standardize Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      
      // 4. Standardize Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}