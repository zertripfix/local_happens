import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_happens/ui/styles/app_button_styles.dart';

ThemeData buildAppTheme() {
  final baseTheme = ThemeData.light();
  return baseTheme.copyWith(
    scaffoldBackgroundColor: Color(0xFFFBFAF9),
    textTheme: GoogleFonts.interTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF404F43),
      primary: Color(0xFF404F43),
      onSurfaceVariant: Color(0xFF79867D),
      surface: Color(0xFFFBFAF9),
      surfaceContainerHighest: Color(0xFFF2F0ED),
      outline: Color(0xFFE8E6E3),
    ),
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.elevated,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonStyles.outlined,
    ),
  );
}
