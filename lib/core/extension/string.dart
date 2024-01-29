
import 'package:flutter/cupertino.dart';

extension StringExtension on String {
  bool isValidEmail() {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(this);
  }
}



extension TextExtension on Text {


  Size measureText({
    required BuildContext context,

  }) {

    print('measure text $data ');

    assert(style?.fontSize != null);
    return (TextPainter(
      text: TextSpan(
        text: '  $data  ',
        style: style!.copyWith(
            fontSize:
            MediaQuery.textScalerOf(context).scale(style!.fontSize!)),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout()).size;
  }
}


