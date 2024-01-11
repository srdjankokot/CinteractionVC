import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'assets/colors/Colors.dart';
import 'assets/strings/Strings.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/app/app.dart';
import 'features/conference/conference_bloc.dart';
import 'features/login_page/bloc/login_bloc.dart';
import 'features/login_page/login_screen.dart';
import 'package:loggy/loggy.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  // runApp(MyApp());

  WidgetsFlutterBinding.ensureInitialized();
  _initLoggy();
  _initGoogleFonts();

  if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
    // initialiaze the facebook javascript SDK
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: "1331067334444014",
      cookie: true,
      xfbml: true,
      version: "v15.0",
    );
  }

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ConferenceBloc()),
          BlocProvider(create: (context) => LoginBloc()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
          ],
          onGenerateTitle: (context) =>
              Strings.getText(StringKey.appTitle, context),
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange,
                primary: ColorConstants.kPrimaryColor,
                secondary: ColorConstants.kSecondaryColor,
              )),
          home: const LoginPage(),
          // home: VideoRoomPage("999888", "Test"),
        ));
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
