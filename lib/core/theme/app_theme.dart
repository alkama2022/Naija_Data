import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Builds the application ThemeData from the prototype design system.
/// The accent color is overridable via [accentColor] to support the
/// theme options exposed in the prototype (#0A7A4C, #0F766E, #1D4ED8, #B45309).
ThemeData buildTheme({Color accentColor = kAccent}) {
  final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: accentColor,
    brightness: Brightness.light,
    primary: accentColor,
    surface: kSurface,
    onPrimary: kTextOnAccent,
    onSurface: kTextPrimary,
  );

  final TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: kFontSizeH1,
      fontWeight: kWeightExtraBold,
      color: kTextPrimary,
      letterSpacing: -0.02,
      height: 1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: kFontSizeHeading,
      fontWeight: kWeightExtraBold,
      color: kTextPrimary,
      letterSpacing: -0.02,
      height: 1.2,
    ),
    titleLarge: TextStyle(
      fontSize: 19.0,
      fontWeight: kWeightBold,
      color: kTextPrimary,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: kFontSizeBody,
      fontWeight: kWeightMedium,
      color: kTextPrimary,
      height: 1.45,
    ),
    bodyMedium: TextStyle(
      fontSize: kFontSizeBody,
      fontWeight: kWeightMedium,
      color: kTextMuted,
      height: 1.45,
    ),
    labelLarge: TextStyle(
      fontSize: kFontSizeLabel,
      fontWeight: kWeightBold,
      color: kTextPrimary,
    ),
  ).apply(fontFamily: kFontFamily);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kBackground,
    fontFamily: kFontFamily,
    textTheme: textTheme,
    primaryColor: accentColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: kTextOnAccent,
        minimumSize: const Size(double.infinity, kButtonMinHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusButton),
        ),
        elevation: 0,
        disabledBackgroundColor: const Color(0xFFBFCBC4),
        disabledForegroundColor: kTextOnAccent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: const BorderSide(width: 1.5, color: kBorderMedium),
        minimumSize: const Size(double.infinity, kButtonMinHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusButton),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kBackground,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusInput),
        borderSide: const BorderSide(width: 1.5, color: kBorderMedium),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusInput),
        borderSide: const BorderSide(width: 1.5, color: kBorderMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusInput),
        borderSide: BorderSide(width: 1.5, color: accentColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusInput),
        borderSide: const BorderSide(width: 1.5, color: Color(0xFF9B1C12)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kBorderRadiusInput),
        borderSide: BorderSide(width: 1.5, color: Color(0xFF9B1C12)),
      ),
      hintStyle: const TextStyle(
        fontSize: kFontSizeButton,
        fontWeight: kWeightMedium,
        color: kTextMuted,
      ),
      labelStyle: const TextStyle(
        fontSize: kFontSizeLabel,
        fontWeight: kWeightBold,
        color: kTextPrimary,
      ),
    ),
    cardTheme: _buildCardTheme(),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
  );
}

CardThemeData _buildCardTheme() {
  return CardThemeData(
    color: kSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(kBorderRadiusCard),
      side: const BorderSide(width: 1.0, color: kCardBorder),
    ),
    elevation: 0,
  );
}
