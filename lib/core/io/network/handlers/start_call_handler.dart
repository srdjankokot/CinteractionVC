import 'package:dio/dio.dart';

import '../urls.dart';
import 'network_handler.dart';

class StartCallHandler extends NetworkHandler<void>
{
  StartCallHandler({required this.streamId, required this.timezone, required this.recording, required this.userId});

  final String streamId;
  final String timezone;
  final int userId;
  final bool recording;

  @override
  Future<Response> createRequest() {
    var formData = FormData.fromMap({'streamId': streamId, 'timezone': timezone, 'user_id': userId, 'recording': recording});
    return dio.post(Urls.startCall, data: formData);
  }

  @override
  void onSuccess(Map<String, dynamic> result) {
    print('$result');
  }

  @override
  void onError(String e) {

  }
}