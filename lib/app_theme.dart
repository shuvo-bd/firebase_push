import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const ink = Color(0xFF24322F);
  static const muted = Color(0xFF78837E);
  static const canvas = Color(0xFFF3F5F1);
  static const green = Color(0xFF477A70);
  static const greenDark = Color(0xFF315D53);
  static const greenSoft = Color(0xFFE3EEE9);
  static const coral = Color(0xFFD8785E);
  static const coralSoft = Color(0xFFF8E7E0);
  static const gold = Color(0xFFD6A34D);
  static const line = Color(0xFFE5E9E4);
}

ThemeData buildAppTheme() {
  final textTheme = GoogleFonts.manropeTextTheme();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      surface: Colors.white,
      error: AppColors.coral,
    ),
    textTheme: textTheme.copyWith(
      headlineMedium: textTheme.headlineMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
    ),
  );
}
