import 'dart:io';



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'assets/strings/Strings.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'features/conference/conference_bloc.dart';
import 'features/login_page/bloc/login_bloc.dart';
import 'features/login_page/login_screen.dart';



void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
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
            primarySwatch: Colors.orange,
          ),
          home: const LoginPage(),
          // home: VideoRoomPage("999888", "Test"),
        ));
  }
}
