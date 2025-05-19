import 'package:cinteraction_vc/core/extension/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../assets/colors/Colors.dart';

final lightTheme = _getTheme();
final darkTheme = _getDarkTheme();

ThemeData getTitleTheme(ColorScheme colorscheme)
{
  return _getTitleTheme(colorscheme);
}
// final titleThemeStyle = _getTitleTheme();

Color _primary = ColorConstants.kPrimaryColor;
Color _secondary = ColorConstants.kSecondaryColor;
Color _border = ColorConstants.kBorder;

Color _background = ColorConstants.kSurface;
Color _lightest = ColorConstants.kSurface;
Color _darkest = ColorConstants.kText;
Color _divider = ColorConstants.kDivider;
Color _disabled = ColorConstants.kDisabled;
Color _title = ColorConstants.kTitle;

Color _red =  ColorConstants.kError;
Color _black =  ColorConstants.kBlack;
MaterialColor _grey =  ColorConstants.kGrey;
MaterialColor _blue =  ColorConstants.kBlue;


final _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  // Primary
  primary: _primary,
  primaryFixed :  ColorConstants.kPrimaryFixed,
  
  onPrimary: _lightest,
  primaryContainer: _primary.withOpacitySafe(0.2),
  onPrimaryContainer: _lightest,
  // Secondary
  secondary: _secondary,
  onSecondary: _darkest,
  secondaryContainer: _secondary.withOpacitySafe(0.2),
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

    outlineVariant: _black,
  inversePrimary: _title,

);


Color _primary_dark = DarkColorConstants.kPrimaryColor;
Color _secondary_dark = DarkColorConstants.kSecondaryColor;
Color _border_dark = DarkColorConstants.kBorder;
Color _title_dark = DarkColorConstants.kTitle;

Color _background_dark = DarkColorConstants.kSurface;
Color _lightest_dark = DarkColorConstants.kSurface;
Color _darkest_dark = DarkColorConstants.kText;
Color _divider_dark = DarkColorConstants.kDivider;
Color _disabled_dark = DarkColorConstants.kDisabled;

Color _red_dark =  DarkColorConstants.kError;
Color _black_dark =  DarkColorConstants.kBlack;
MaterialColor _grey_dark =  DarkColorConstants.kGrey;
MaterialColor _blue_dark =  DarkColorConstants.kBlue;



final _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    // Primary
    primary: _primary_dark,
    primaryFixed :  DarkColorConstants.kPrimaryFixed,

    onPrimary: _lightest_dark,
    primaryContainer: _primary_dark.withOpacitySafe(0.2),
    onPrimaryContainer: _lightest_dark,
    // Secondary
    secondary: _secondary_dark,
    onSecondary: _darkest_dark,
    secondaryContainer: _secondary_dark.withOpacitySafe(0.2),
    onSecondaryContainer: _darkest_dark,
    // Error
    error: _red_dark,
    onError: _lightest_dark,
    // Background
    background: _background_dark,
    onBackground: _darkest_dark,
    // Surface
    surface: _lightest_dark,
    onSurface: _darkest_dark,
    // Outline
    outline: _divider_dark,

    outlineVariant: _black_dark,
  inversePrimary: _title_dark,
);



ThemeData _getTheme() {
  final colorScheme = _lightColorScheme;
  final monteserratTextTheme = _getMonteserratTextTheme(colorScheme);
  final primaryTextTheme = monteserratTextTheme;

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(71),
  );
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 18,
  );

  var buttonTextStyle = primaryTextTheme.displaySmall;


  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    textTheme: monteserratTextTheme,
    primaryTextTheme: primaryTextTheme,
    scaffoldBackgroundColor: colorScheme.background,
    disabledColor: _disabled,
    dividerTheme:  DividerThemeData(
      color: _divider,
      space: 1,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      labelStyle: monteserratTextTheme.labelSmall,
      side: const BorderSide(
        width: 0,
      ),
    ),
    cardTheme:  CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
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
      surfaceTintColor: colorScheme.surface,
    ),
    bottomSheetTheme:  BottomSheetThemeData(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
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
      titleTextStyle: monteserratTextTheme.bodyLarge,
      backgroundColor: _secondary,
      centerTitle: true,
      foregroundColor: colorScheme.surface,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.background,
      surfaceTintColor: colorScheme.background,
      titleTextStyle: monteserratTextTheme.titleLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkest,
      contentTextStyle: primaryTextTheme.displaySmall,
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
      border:  OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: const BorderRadius.all(Radius.circular(71)),
      ),
      enabledBorder:  OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: const BorderRadius.all(Radius.circular(71)),
      ),
      focusedBorder:  OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border),
        borderRadius: const BorderRadius.all(Radius.circular(71)),
      ),
      hintStyle: monteserratTextTheme.bodySmall,
      labelStyle: monteserratTextTheme.bodySmall!.copyWith(
        color: colorScheme.outlineVariant.withOpacitySafe(0.38),
        fontWeight: FontWeight.normal,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.surface,
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
  ).copyWith(
    extensions: <ThemeExtension<dynamic>>[
      CustomColorExtension(
        kBlue: _blue,
        kGrey: _grey,
        customGreyColor: const Color(0xFFBDBDBD),
        customBlackColor: const Color(0xFF212121),
      ),
    ],
  )


  ;
}
ThemeData _getDarkTheme() {
  final colorScheme = _darkColorScheme;
  final monteserratTextTheme = _getMonteserratTextTheme(colorScheme);
  final primaryTextTheme = monteserratTextTheme;

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(71),
  );
  const buttonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 18,
  );

  var buttonTextStyle = primaryTextTheme.displaySmall;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: monteserratTextTheme,
    primaryTextTheme: primaryTextTheme,
    scaffoldBackgroundColor: colorScheme.background,
    disabledColor: _disabled_dark,
    dividerTheme:  DividerThemeData(
      color: _divider_dark,
      space: 1,
      thickness: 1,
    ),
    chipTheme: ChipThemeData(
      labelStyle: monteserratTextTheme.labelSmall,
      side: const BorderSide(
        width: 0,
      ),
    ),
    cardTheme:  CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        side: BorderSide(
          width: 1,
          color: _divider_dark,
        ),
      ),
      color: _background_dark,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: _background_dark,
      surfaceTintColor: colorScheme.background,
    ),
    bottomSheetTheme:  BottomSheetThemeData(
      backgroundColor: _background_dark,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
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
      titleTextStyle: monteserratTextTheme.bodyLarge,
      backgroundColor: _secondary_dark,
      centerTitle: true,
      foregroundColor: colorScheme.surface,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: colorScheme.background,
      surfaceTintColor: colorScheme.background,
      titleTextStyle: monteserratTextTheme.titleLarge,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkest_dark,
      contentTextStyle: primaryTextTheme.displaySmall,
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
      border:  OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border_dark),
        borderRadius: const BorderRadius.all(Radius.circular(71)),
      ),
      enabledBorder:  OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border_dark),
        borderRadius: const BorderRadius.all(Radius.circular(71)),
      ),
      focusedBorder:  OutlineInputBorder(
        // borderRadius: BorderRadius.all(Radius.circular(71)),
        // borderSide: BorderSide.none,
        borderSide: BorderSide(width: 1, color: _border_dark),
        borderRadius: const BorderRadius.all(Radius.circular(71)),
      ),
      hintStyle: monteserratTextTheme.bodySmall,
      labelStyle: monteserratTextTheme.bodySmall!.copyWith(
        color: colorScheme.outlineVariant.withOpacitySafe(0.38),
        fontWeight: FontWeight.normal,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.surface,
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
  ).copyWith(
    extensions: <ThemeExtension<dynamic>>[
      CustomColorExtension(
        kBlue: _blue_dark,
        kGrey: _grey_dark,
        customGreyColor: const Color(0xFFBDBDBD),
        customBlackColor: const Color(0xFF212121),
      ),
    ],
  );
}
ThemeData _getTitleTheme(ColorScheme colorScheme) {

  var nunitoTextTheme = getNunitoTextTheme(colorScheme);
  final primaryTextTheme = nunitoTextTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: nunitoTextTheme,
    primaryTextTheme: primaryTextTheme,
  );
}

const minFontSize = 12.0;

TextTheme getNunitoTextTheme(ColorScheme colorScheme) {
  Color color = colorScheme.inversePrimary;
  const headingWeight = FontWeight.w700;

  TextTheme textTheme = TextTheme(
    // Headline
    headlineLarge: TextStyle(
      fontSize: minFontSize * 3.57, //50,
      color: color,
      fontWeight: headingWeight,
    ),
    headlineMedium: TextStyle(
      fontSize: minFontSize * 3.21, //45,
      color: color,
      fontWeight: headingWeight,
    ),
    headlineSmall: TextStyle(
      fontSize: minFontSize * 2.857, //40,
      color: color,
      fontWeight: headingWeight,
    ),

    // Title
    titleLarge: TextStyle(
      fontSize: minFontSize * 2.285, //32,
      color: color,
      fontWeight: headingWeight,
    ),
    titleMedium: TextStyle(
      fontSize: minFontSize * 1.71, //24,
      color: color,
      fontWeight: headingWeight,
    ),
    titleSmall: TextStyle(
      fontSize: minFontSize * 1.43, //20,
      color: color,
      fontWeight: FontWeight.w600,
    ),
  );
  return GoogleFonts.nunitoTextTheme(textTheme);
}

TextTheme _getMonteserratTextTheme(ColorScheme colorScheme) {
  Color color = colorScheme.onSecondary;
  const bodyWeight = FontWeight.w400;

  TextTheme textTheme = TextTheme(
    // Display
    displayLarge: TextStyle(
      fontSize: minFontSize * 1.43, //20,
      color: color,
      fontWeight: FontWeight.w600,
    ),
    displayMedium: TextStyle(
      fontSize: minFontSize * 1.285, //18,
      color: color,
      fontWeight: FontWeight.w700,
    ),
    displaySmall: TextStyle(
      fontSize: minFontSize * 1.15, //16,
      color: color,
      fontWeight: FontWeight.w600,
    ),

    // Body
    bodyLarge: TextStyle(
      fontSize: minFontSize * 1.43, //20,
      color: color,
      fontWeight: bodyWeight,
    ),
    bodyMedium: TextStyle(
      fontSize: minFontSize * 1.285, //18,
      color: color,
      fontWeight: bodyWeight,
    ),
    bodySmall: TextStyle(
      fontSize: minFontSize * 1.15, //16
      color: color,
      fontWeight: bodyWeight,
    ),

    // Label
    labelLarge: TextStyle(
      fontSize: minFontSize, //14
      color: color,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontSize: minFontSize, //14
      color: color,
      fontWeight: bodyWeight,
    ),
  );

  return GoogleFonts.nunitoTextTheme(textTheme);
}

class CustomColors {
  final MaterialColor kGrey;
  final Color customGreyColor;
  final Color customBlackColor;

  const CustomColors({
    required this.kGrey,
    required this.customGreyColor,
    required this.customBlackColor,
  });
}


@immutable
class CustomColorExtension extends ThemeExtension<CustomColorExtension> {
  final Color customGreyColor;
  final Color customBlackColor;
  final MaterialColor kGrey;
  final MaterialColor kBlue;

  const CustomColorExtension({
    required this.customGreyColor,
    required this.customBlackColor,
    required this.kGrey,
    required this.kBlue,
  });

  @override
  CustomColorExtension copyWith({
    Color? customGreyColor,
    Color? customBlackColor,
    MaterialColor? kGrey,
    MaterialColor? kBlue,
  }) {
    return CustomColorExtension(
      customGreyColor: customGreyColor ?? this.customGreyColor,
      customBlackColor: customBlackColor ?? this.customBlackColor,
      kGrey: kGrey ?? this.kGrey,
      kBlue: kBlue ?? this.kBlue,
    );
  }

  @override
  CustomColorExtension lerp(ThemeExtension<CustomColorExtension>? other, double t) {
    if (other is! CustomColorExtension) return this;
    return CustomColorExtension(
      customGreyColor: Color.lerp(customGreyColor, other.customGreyColor, t)!,
      customBlackColor: Color.lerp(customBlackColor, other.customBlackColor, t)!,
      // MaterialColor lerp isn't built-in, so we just keep the original or switch directly
      kGrey: t < 0.5 ? kGrey : other.kGrey,
      kBlue: t < 0.5 ? kBlue : other.kBlue,
    );
  }
}
