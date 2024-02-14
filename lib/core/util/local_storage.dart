

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

const String keyAccessToken = 'access_token';

// to save token in local storage
void saveAccessToken(String accessToken) async{
  await storage.write(key: keyAccessToken, value: accessToken);
  print('Access token is saved');
}

Future<String?> getAccessToken() async {
  print(storage.read(key: keyAccessToken));
  return  storage.read(key: keyAccessToken);
}