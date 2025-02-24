import 'package:cinteraction_vc/core/app/style.dart';
import 'package:cinteraction_vc/core/extension/router.dart';
import 'package:cinteraction_vc/core/io/network/urls.dart';
import 'package:cinteraction_vc/layers/data/repos/auth_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/repos/chat_repo_impl.dart';
import 'package:cinteraction_vc/layers/data/source/network/api_impl.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../layers/data/source/local/local_storage.dart';
import '../app/injector.dart';
import '../ui/widget/responsive.dart';
import 'package:flutter/foundation.dart';

import '../util/secure_local_storage.dart';

extension Context on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  TextTheme get titleTheme => titleThemeStyle.textTheme;
  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  void closeKeyboard() => FocusScope.of(this).unfocus();

  void showSnackBarMessage(
    String message, {
    bool isError = false,
  }) {
    final theme = Theme.of(this);
    final Color? foregroundColor;
    final Color? backgroundColor;
    if (isError) {
      foregroundColor = theme.colorScheme.onError;
      backgroundColor = theme.colorScheme.error;
    } else {
      foregroundColor = Colors.white;
      backgroundColor = null;
    }

    ScaffoldMessenger.of(this)
        .showSnackBar(
          SnackBar(
            backgroundColor: backgroundColor,
            content: Text(
              message,
              style: TextStyle(color: foregroundColor),
            ),
          ),
        )
        .closed
        .then((reason) => print('------------ $reason'));
  }

  bool get isWide {
    // return  kIsWeb;
    // final isMobile = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
    // return !isMobile;

    final maxWidth = MediaQuery.sizeOf(this).width;
    return maxWidth > desktopWidthBreakpoint;
  }

  void logOut() async {
    saveAccessToken(null);
    getIt.get<LocalStorage>().clearUser();
    resetAndReinitialize();
    GoRouter.of(this).clearStackAndNavigate('/auth');
  }

  // void logOut() async {
  //   Dio dio = await getIt.getAsync<Dio>();
  //   final accessToken = await getAccessToken();
  //   print('accessToken $accessToken');
  //   Response response = await dio.post(
  //     Urls.logOutEndpoint,
  //     options: Options(
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //     ),
  //   );
  //   if (response.statusCode == 200) {
  //     print('Logout successful.');
  //     await saveAccessToken(null);
  //     getIt.get<LocalStorage>().clearUser();
  //     getIt.get<ChatRepo>().leaveRoom();
  //     GoRouter.of(this).clearStackAndNavigate('/auth');
  //   } else {
  //     print('LogOut failed, ${response.statusCode}');
  //   }
  // }
}
