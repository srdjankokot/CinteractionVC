import 'package:flutter/material.dart';

class ColorConstants {

  static const kPrimaryColor = Color(0xFFbc101c);
  static const kSecondaryColor = Color(0xFF403736);
  static const  kSurface = Color(0xFFFFFFFF);
  static const kBlack = Color(0xFF000000);
  static const kDisabled = Color(0xFF9E9E9E);
  static const kText = Color(0xFF333333);
  static const kTitle = Color(0xFF4F4F4F);
  static const kBorder = Color(0xFFBDBDBD);
  static const kDivider = Color(0xFFE0E0E0);
  static const kPrimaryFixed = Color(0xFFF1691C);
  static const kError = Color(0xFFF44336);


  static const MaterialColor kGrey = MaterialColor(_greyPrimaryValue, <int, Color>{
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE0E0E0),
    350: Color(0xFFD6D6D6), // only for raised button while pressed in light theme
    400: Color(0xFFBDBDBD),
    500: Color(_greyPrimaryValue),
    600: Color(0xFF757575),
    700: Color(0xFF616161),
    800: Color(0xFF424242),
    850: Color(0xFF303030), // only for background color in dark theme
    900: Color(0xFF212121),
  });
  static const int _greyPrimaryValue = 0xFF9E9E9E;


  static const MaterialColor kBlue = MaterialColor(_bluePrimaryValue, <int, Color>{
    50: Color(0xFFE3F2FD),
    100: Color(0xFFBBDEFB),
    200: Color(0xFF90CAF9),
    300: Color(0xFF64B5F6),
    400: Color(0xFF42A5F5),
    500: Color(_bluePrimaryValue),
    600: Color(0xFF1E88E5),
    700: Color(0xFF1976D2),
    800: Color(0xFF1565C0),
    900: Color(0xFF0D47A1),
  });

  static const int _bluePrimaryValue = 0xFF2196F3;
  static const kGray600 = Color(0xFF475466);




  static const kStateInfo = Color(0xFF24408B);
  static const kStateSuccess = Color(0xFF1CBC96);
  static const kStateWarning = Color(0xFFEFBA32);


  static const conferenceBackground = Color(0xFF222222);
  static const kEngProgress65 = Color(0xFFA9A31A);

  static const  kGreen = Color(0xFF4CAF50);
  static const  kBlueGrey = Color(0xFF607D8B);
  static const  kAmber = Color(0xFFFFC107);
}


class DarkColorConstants{

// Primary & Secondary (unchanged or slightly tweaked if needed)
  static const kPrimaryColor = Color(0xFFbc101c); // unchanged, strong brand color
  static const kSecondaryColor = Color(0xFFE0DAD9); // lighter version for contrast

// Surfaces
  static const kSurface = Color(0xFF121212); // typical dark surface
  static const kBlack = Color(0xFFFFFFFF); // inverse of light theme
  static const kDisabled = Color(0xFF757575); // lighter for dark bg
  static const kText = Color(0xFFE0E0E0); // light text on dark bg
  static const kTitle = Color(0xFFCCCCCC); // light grey for titles
  static const kBorder = Color(0xFF616161); // soft border in dark
  static const kDivider = Color(0xFF424242); // darker divider
  static const kPrimaryFixed = Color(0xFFFFA57F); // softer variation of orange for dark
  static const kError = Color(0xFFF28B82); // error color softened for dark

// Greys
  static const MaterialColor kGrey = MaterialColor(_greyPrimaryValueDark, <int, Color>{
    50: Color(0xFF303030),
    100: Color(0xFF383838),
    200: Color(0xFF424242),
    300: Color(0xFF4E4E4E),
    350: Color(0xFF5A5A5A), // For pressed state
    400: Color(0xFF616161),
    500: Color(_greyPrimaryValueDark),
    600: Color(0xFF9E9E9E),
    700: Color(0xFFBDBDBD),
    800: Color(0xFFD6D6D6),
    850: Color(0xFFE0E0E0), // For background overlay
    900: Color(0xFFF5F5F5),
  });
  static const int _greyPrimaryValueDark = 0xFF757575;

// Blues
  static const MaterialColor kBlue = MaterialColor(_bluePrimaryValue, <int, Color>{
    50: Color(0xFF0D47A1),
    100: Color(0xFF1565C0),
    200: Color(0xFF1976D2),
    300: Color(0xFF1E88E5),
    400: Color(0xFF2196F3),
    500: Color(_bluePrimaryValue),
    600: Color(0xFF42A5F5),
    700: Color(0xFF64B5F6),
    800: Color(0xFF90CAF9),
    900: Color(0xFFBBDEFB),
  });
  static const int _bluePrimaryValue = 0xFF2196F3;

// State colors
  static const kStateInfo = Color(0xFF6D9EFF);     // adjusted for dark
  static const kStateSuccess = Color(0xFF1CBC96);  // works well on dark too
  static const kStateWarning = Color(0xFFFFD54F);  // warm, readable yellow

// Additional
  static const kGray600 = Color(0xFFB0BEC5); // lighter blue-grey
  static const conferenceBackground = Color(0xFF121212); // better for dark
  static const kEngProgress65 = Color(0xFFE6E675); // visible yellow-green on dark

  static const kGreen = Color(0xFF81C784); // green with good dark contrast
  static const kBlueGrey = Color(0xFF90A4AE); // lighter for dark theme
  static const kAmber = Color(0xFFFFD740); // bright amber for dark

}
