import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app/app.dart';
import 'package:loggy/loggy.dart';

import 'core/app/injector.dart';
import 'core/util/nonweb_url_strategy.dart' if (dart.library.html) 'core/util/web_url_strategy.dart';


late SharedPreferences sharedPref;

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  _initLoggy();
  _initGoogleFonts();

  await initializeGetIt();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
    // initialiaze the facebook javascript SDK
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "1331067334444014",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

  sharedPref = await SharedPreferences.getInstance();

  configureUrl();
  runApp(const CinteractionFlutterApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void _initLoggy() {
  Loggy.initLoggy(
    logOptions: const LogOptions(
      LogLevel.all,
      stackTraceLevel: LogLevel.warning,
    ),
    logPrinter: const PrettyPrinter(),
  );
}

void _initGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}
