import 'package:flutter/material.dart';

import '../../../assets/colors/Colors.dart';

class CallButtonShape extends StatelessWidget {
  final Widget image;
  final VoidCallback? onClickAction;
  final Color bgColor;

  const CallButtonShape(
      {super.key,
      required this.image,
      required this.onClickAction,
      this.bgColor = ColorConstants.kWhite30});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 53,
      height: 53,
      decoration: ShapeDecoration(
        color: bgColor,
        shape: const OvalBorder(),
      ),
      child: IconButton(icon: image, onPressed: onClickAction),
    );
  }
}
