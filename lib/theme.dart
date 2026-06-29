import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static const Color primary     = Color(0xFF1565C0); // deep blue
  static const Color primaryLight= Color(0xFF1E88E5); // medium blue
  static const Color primaryDark = Color(0xFF0D47A1); // dark blue
  static const Color surface     = Color(0xFFF0F4FF); // light blue bg
  static const Color cardBg      = Color(0xFFFFFFFF);
  static const Color textDark    = Color(0xFF1A237E);
  static const Color textMid     = Color(0xFF6B7280);
  static const Color textLight   = Color(0xFFD1D5DB);


  static const Color success     = Color(0xFF2E7D32); // green - Done
  static const Color successBg   = Color(0xFFE8F5E9);
  static const Color danger      = Color(0xFFC62828); // red - Delete
  static const Color dangerBg    = Color(0xFFFFEBEE);
  static const Color warning     = Color(0xFFE65100); // orange - Urgent
  static const Color warningBg   = Color(0xFFFFF3E0);
  static const Color overdue     = Color(0xFF6A1B9A); // purple - Overdue
  static const Color overdueBg   = Color(0xFFF3E5F5);
  static const Color incomplete  = Color(0xFF1565C0); // blue - Incomplete
  static const Color incompleteBg= Color(0xFFE3F2FD);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800, color: textDark, fontSize: 32),
        headlineMedium: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700, color: textDark, fontSize: 22),
        bodyLarge: GoogleFonts.plusJakartaSans(color: textDark, fontSize: 15),
        bodyMedium: GoogleFonts.plusJakartaSans(color: textMid, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.plusJakartaSans(color: textLight, fontSize: 14),
        labelStyle: GoogleFonts.plusJakartaSans(color: textMid, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: textLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: danger),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}
