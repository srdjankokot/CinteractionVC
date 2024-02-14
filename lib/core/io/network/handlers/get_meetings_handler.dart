import 'dart:async';

import 'package:cinteraction_vc/core/io/network/models/login_response.dart';
import 'package:cinteraction_vc/core/io/network/urls.dart';
import 'package:cinteraction_vc/core/util/local_storage.dart';
import 'package:dio/dio.dart';

import 'network_handler.dart';

class GetMeetings extends NetworkHandler<LoginResponse>
{
  GetMeetings();

  @override
  Future<Response> createRequest() {
    return dio.get(Urls.meetings);
  }

  @override
  void onSuccess(Map<String, dynamic> result) {
    // print('$result');
  }

  @override
  void onError(String e) {
  print(e);
  }
}

