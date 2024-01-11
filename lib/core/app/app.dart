import 'package:cinteraction_vc/core/app/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../navigation/router.dart';
import 'di.dart';

class CinteractionFlutterApp extends StatelessWidget {
  const CinteractionFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DI(
      child: MaterialApp.router(
        title: 'Cinteraction Flutter App',
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
