import 'package:cinteraction_vc/core/extension/color.dart';
import 'package:flutter/material.dart';

import '../../../assets/colors/Colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.loading,
    required this.child,
    super.key,
  });

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      return child;
    }

    return Stack(
      children: [
        child,
        ColoredBox(
          color: ColorUtil.getColorScheme(context).outlineVariant.withOpacitySafe(0.38),
          child:  const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}
