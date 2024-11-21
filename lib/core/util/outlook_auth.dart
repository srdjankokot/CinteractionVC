import 'package:cinteraction_vc/core/util/secure_local_storage.dart';

import 'dart:html' as html;

Future<void> sendAccessToParent() async {
  print('___Trying to send token____');
  final accessToken = await getAccessToken();

  final jsCode = 'window.parent.postMessage("success:$accessToken", "*");';
  html.window.postMessage(jsCode, "*");
}
