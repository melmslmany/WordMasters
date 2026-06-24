import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/word_language.dart';
import '../constants/app_colors.dart';

abstract final class AppTheme {
  /// UI text theme whose font supports the script of the active UI language.
  ///
  /// Outfit (the default) only covers Latin, so Cyrillic (Russian) and
  /// Devanagari (Hindi) would render as missing-glyph boxes. We pick a font
  /// that covers each script.
  static TextTheme _baseTextTheme(String langCode) {
    switch (langCode) {
      case 'ar':
        return GoogleFonts.cairoTextTheme();
      case 'hi':
        return GoogleFonts.poppinsTextTheme();
      case 'ru':
        return GoogleFonts.montserratTextTheme();
      default:
        return GoogleFonts.outfitTextTheme();
    }
  }

  /// Font family for canvas-drawn grid letters, chosen by the word script so
  /// Cyrillic / Arabic / Latin glyphs all render correctly.
  static String? gridFontFamily(WordLanguage language) {
    switch (language.script) {
      case LetterScript.arabic:
        return GoogleFonts.cairo().fontFamily;
      case LetterScript.cyrillic:
        return GoogleFonts.montserrat().fontFamily;
      case LetterScript.latin:
        return GoogleFonts.outfit().fontFamily;
    }
  }

  static ThemeData dark({required String langCode}) {
    final baseFont = _baseTextTheme(langCode);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonPurple,
        secondary: AppColors.neonCyan,
        surface: AppColors.surface,
      ),
      textTheme: baseFont.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
