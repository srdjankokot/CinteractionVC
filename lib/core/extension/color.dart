import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app/style.dart';

extension ColorExtension on Color {
  Color withOpacitySafe(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity must be between 0.0 and 1.0');
    return withAlpha((opacity * 255).round());
  }



}

class ColorUtil{

  static CustomColorExtension? getColor(BuildContext context)
  {
    return Theme.of(context).extension<CustomColorExtension>();
  }


  static ColorScheme getColorScheme(BuildContext context) {
    return Theme
        .of(context)
        .colorScheme;
  }
}