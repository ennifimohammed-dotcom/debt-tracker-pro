import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors
  static const Color bg = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgCard2 = Color(0xFF1A2235);
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE2C47A);
  static const Color green = Color(0xFF00C896);
  static const Color red = Color(0xFFFF4757);
  static const Color textPrimary = Color(0xFFEAEEF4);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color border = Color(0xFF1F2D47);

  static ThemeData get theme => ThemeData(
        fontFamily: 'Cairo',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: green,
          surface: bgCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardTheme(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgCard2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: gold, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: red),
          ),
          hintStyle: const TextStyle(color: textSecondary, fontFamily: 'Cairo'),
          labelStyle: const TextStyle(color: textSecondary, fontFamily: 'Cairo'),
          prefixIconColor: textSecondary,
        ),
      );

  static LinearGradient get goldGradient => const LinearGradient(
        colors: [Color(0xFFC9A84C), Color(0xFFE2C47A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get bgGradient => const LinearGradient(
        colors: [Color(0xFF0A0E1A), Color(0xFF0D1526)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static BoxDecoration get glassCard => BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2D47), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration goldGlassCard(BuildContext context) => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFC9A84C).withOpacity(0.12),
            const Color(0xFFC9A84C).withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFC9A84C).withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC9A84C).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
