import 'dart:async';

import 'package:cinteraction_vc/core/ui/images/image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/navigation/route.dart';
import '../../../../assets/colors/Colors.dart';
import '../../../../core/extension/color.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      AppRoute.auth.go(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    return  Container(
      decoration:   BoxDecoration(color: ColorUtil.getColorScheme(context).surface),
      child: Center(child: imageSVGAsset('original_long_logo') as Widget)
    );

  }
}