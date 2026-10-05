import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF08344C);
  static const blue = Color(0xFF8FD2EE);
  static const darkBlue = Color(0xFF2F7898);
  static const green = Color(0xFFB6E5A6);
  static const paleGreen = Color(0xFFD7F1CE);
  static const paleBlue = Color(0xFFE8F2F8);
  static const muted = Color(0xFF718795);
  static const border = Color(0xFFD5E4ED);
  static const background = Color(0xFFF9FCFD);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
      fontFamily: 'Arial',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

BoxDecoration appCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(18),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0808344C),
        blurRadius: 18,
        offset: Offset(0, 5),
      ),
    ],
  );
}
