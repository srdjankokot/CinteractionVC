import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../assets/colors/Colors.dart';

final lightTheme = _getTheme();

const _primary = ColorConstants.kPrimaryColor;
const _secondary = ColorConstants.kSecondaryColor;
const _border = ColorConstants.kGrey200;

const _background = Colors.white;
const _lightest = Colors.white;
const _darkest = ColorConstants.kGrey400;
const _darker = Colors.black87;
const _divider = ColorConstants.kDividerGray;
const _disabled = Colors.grey;

const _red = Colors.red;

final _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  // Primary
  primary: _primary,
  onPrimary: _lightest,
  primaryContainer: _primary.withOpacity(0.2),
  onPrimaryContainer: _lightest,
  // Secondary
  secondary: _secondary,
  onSecondary: _darkest,
  secondaryContainer: _secondary.withOpacity(0.2),
  onSecondaryContainer: _darkest,
  // Error
  error: _red,
  onError: _lightest,
  // Background
  background: _background,
  onBackground: _darkest,
  // Surface
  surface: _lightest,
  onSurface: _darkest,
  // Outline
  outline: _divider,
);

ThemeData _getTheme() {
  final colorScheme = _lightColorScheme;
  final textTheme = _getTextTheme(colorScheme);
  final primaryTextTheme = textTheme.apply(
    displayColor: colorScheme.onPrimary,
    bodyColor: colorScheme.onPrimary,
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(71),
  );
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 18,
  );


  const buttonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w500,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: primaryTextTheme,
    scaffoldBackgroundColor: colorScheme.background,
    disabledColor: _disabled,
    dividerTheme: const DividerThemeData(
      color: _divider,
      space: 1,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      labelStyle: textTheme.labelSmall,
      side: const BorderSide(
        width: 0,
      ),
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        side: BorderSide(
          width: 1,
          color: _divider,
        ),
      ),
      color: _background,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _background,
      surfaceTintColor: colorScheme.background,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      labelType: NavigationRailLabelType.all,
      groupAlignment: 0,
    ),
    appBarTheme: AppBarTheme(
      titleTextStyle: textTheme.titleLarge,
      backgroundColor: _background,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.background,
      surfaceTintColor: colorScheme.background,
      titleTextStyle: textTheme.titleLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkest,
      contentTextStyle: primaryTextTheme.bodyLarge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      border: const OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: BorderRadius.all(Radius.circular(71)),
      ),
      enabledBorder: const OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: BorderRadius.all(Radius.circular(71)),
      ),
      focusedBorder: const OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: BorderRadius.all(Radius.circular(71)),
      ),
      hintStyle: textTheme.bodyLarge,
      labelStyle: textTheme.bodyLarge!.copyWith(
        color: Colors.black38,
        fontWeight: FontWeight.normal,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: Colors.white,
      iconSize: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: buttonTextStyle,
        elevation: 1,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        side: BorderSide(
          color: colorScheme.primary,
          width: 1,
        ),
        foregroundColor: colorScheme.primary,
        textStyle: buttonTextStyle,
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: buttonShape,
        padding: buttonPadding,
        foregroundColor: colorScheme.primary,
        textStyle: buttonTextStyle,
      ),
    ),
  );
}

TextTheme _getTextTheme(ColorScheme colorScheme) {
  const headlineColor = _secondary;
  const headlineWeight = FontWeight.w400;
  const headlineHeight = 1.2;
  const headlineLetterSpacing = 1.0;

  const titleColor = _darkest;
  const titleWeight = FontWeight.bold;
  const titleHeight = 1.2;
  const titleLetterSpacing = 1.0;

  const bodyColor = _darker;
  const bodyWeight = FontWeight.w400;
  const bodyHeight = 1.0;
  const bodyLetterSpacing = 1.0;

  const labelColor = titleColor;

  const textTheme = TextTheme(
    // Headline
    headlineLarge: TextStyle(
      fontSize: 32,
      height: headlineHeight,
      color: headlineColor,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      fontSize: 32,
      height: headlineHeight,
      letterSpacing: headlineLetterSpacing,
      color: headlineColor,
      fontWeight: headlineWeight,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      height: headlineHeight,
      letterSpacing: headlineLetterSpacing,
      color: headlineColor,
      fontWeight: headlineWeight,
    ),

    // Title
    titleLarge: TextStyle(
      fontSize: 20,
      height: titleHeight,
      letterSpacing: titleLetterSpacing,
      color: titleColor,
      fontWeight: titleWeight,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      height: titleHeight,
      letterSpacing: titleLetterSpacing,
      color: titleColor,
      fontWeight: titleWeight,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: titleHeight,
      letterSpacing: titleLetterSpacing,
      color: titleColor,
      fontWeight: titleWeight,
    ),

    // Body
    bodyLarge: TextStyle(
      fontSize: 16,
      height: bodyHeight,
      letterSpacing: bodyLetterSpacing,
      color: bodyColor,
      fontWeight: bodyWeight,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      height: bodyHeight,
      letterSpacing: bodyLetterSpacing,
      color: bodyColor,
      fontWeight: bodyWeight,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: bodyHeight,
      color: bodyColor,
      fontWeight: bodyWeight,
    ),

    // Label
    labelLarge: TextStyle(
      fontSize: 18,
      height: bodyHeight,
      letterSpacing: bodyLetterSpacing,
      color: labelColor,
      fontWeight: bodyWeight,
    ),
    labelMedium: TextStyle(
      fontSize: 16,
      height: bodyHeight,
      letterSpacing: bodyLetterSpacing,
      color: labelColor,
      fontWeight: bodyWeight,
    ),
    labelSmall: TextStyle(
      fontSize: 14,
      height: bodyHeight,
      letterSpacing: bodyLetterSpacing,
      color: labelColor,
      fontWeight: bodyWeight,
    ),
  );
    return GoogleFonts.montserratTextTheme(textTheme);
}
