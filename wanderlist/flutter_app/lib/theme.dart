import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color terra = Color(0xFFC45C26);
  static const Color terraLight = Color(0xFFE8825A);
  static const Color terraDark = Color(0xFF9B3E14);
  static const Color sage = Color(0xFF5C7A5C);
  static const Color sageLight = Color(0xFF8FAF8F);
  static const Color inkColor = Color(0xFF1C1917);
  static const Color inkLight = Color(0xFF44403C);
  static const Color paper = Color(0xFFFAF7F2);
  static const Color paperDark = Color(0xFFF0EBE3);
  static const Color skyColor = Color(0xFF4A7FA5);

  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: terra,
      brightness: Brightness.light,
      surface: paper,
      primary: terra,
      secondary: sage,
    );

    return ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: paper,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: inkColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: inkColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: terra,
        unselectedItemColor: inkLight,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: paperDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inkColor.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inkColor.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: terra, width: 2),
        ),
        labelStyle: TextStyle(color: inkColor.withOpacity(0.6)),
        hintStyle: TextStyle(color: inkColor.withOpacity(0.35)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: terra,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: inkColor,
          side: BorderSide(color: inkColor.withOpacity(0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: paperDark,
        labelStyle: const TextStyle(fontSize: 12, color: inkLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      dividerTheme: const DividerThemeData(
        color: paperDark,
        space: 1,
        thickness: 1,
      ),

      textTheme: const TextTheme(
        displaySmall: TextStyle(fontWeight: FontWeight.w700, color: inkColor, fontSize: 28),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: inkColor, fontSize: 22),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600, color: inkColor, fontSize: 18),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: inkColor, fontSize: 16),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: inkColor, fontSize: 14),
        bodyLarge: TextStyle(color: inkColor, fontSize: 15),
        bodyMedium: TextStyle(color: inkColor, fontSize: 13),
        bodySmall: TextStyle(color: inkLight, fontSize: 12),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}
