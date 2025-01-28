import 'dart:io';

import 'package:cinteraction_vc/layers/presentation/cubit/home/home_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app/app.dart';
import 'package:loggy/loggy.dart';

import 'core/app/injector.dart';
import 'core/util/nonweb_url_strategy.dart' if (dart.library.html) 'core/util/web_url_strategy.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late SharedPreferences sharedPref;

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  _initLoggy();
  _initGoogleFonts();

  sharedPref = await SharedPreferences.getInstance();
  await initializeGetIt();

  GoRouter.optionURLReflectsImperativeAPIs = true;


  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );


  // if (defaultTargetPlatform != TargetPlatform.windows) {
  // window currently don't support storage emulator
  // final emulatorHost =
  // (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
  //     ? '10.0.2.2'
  //     : 'localhost';
  //
  // await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
  // }

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
