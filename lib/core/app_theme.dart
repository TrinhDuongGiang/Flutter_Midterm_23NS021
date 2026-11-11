
import 'package:flutter/material.dart';

class AppTheme {
  // Official five-color palette
  static const Color cloudBlue = Color(0xFFC0DBFF);
  static const Color babyBlue = Color(0xFFA7CCFF);
  static const Color lavender = Color(0xFFC5C0FF);
  static const Color softLilac = Color(0xFFE8E6FF);
  static const Color snowWhite = Color(0xFFF5F8FF);

  static const Color primary = Color(0xFF7977E8);
  static const Color secondary = lavender;
  static const Color lightBlue = cloudBlue;
  static const Color background = snowWhite;
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF242C56);
  static const Color textSecondary = Color(0xFF7B85A5);
  static const Color success = Color(0xFF75C9A7);
  static const Color danger = Color(0xFFFF8E9E);

  static const LinearGradient pastelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cloudBlue,
      softLilac,
      lavender,
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF829BFA),
      Color(0xFF9579ED),
    ],
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lavender,
        primary: primary,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: softLilac),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: lavender,
            width: 2,
          ),
        ),
      ),
    );
  }
}
