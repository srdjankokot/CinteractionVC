import 'dart:async';

import 'package:cinteraction_vc/core/io/network/models/login_response.dart';
import 'package:cinteraction_vc/core/io/network/urls.dart';
import 'package:cinteraction_vc/core/util/local_storage.dart';
import 'package:dio/dio.dart';

import 'network_handler.dart';

class SignIn extends NetworkHandler<LoginResponse>
{
  SignIn({required this.email, required this.password});

  final String email;
  final String password;

  @override
  Future<Response> createRequest() {
    var formData = FormData.fromMap({'email': email, 'password': password});
    return dio.post(Urls.loginEndpoint, data: formData);
  }

  @override
  void onSuccess(Map<String, dynamic> result) {
    print('$result');
    var login = LoginResponse.fromJson(result);

    saveAccessToken('${login.tokenType} ${login.accessToken}');
  }

  @override
  void onError(String e) {

  }
}

