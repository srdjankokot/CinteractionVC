import 'package:dio/dio.dart';

import '../../../util/local_storage.dart';

abstract class NetworkHandler<T>{

  Dio dio = Dio(
      BaseOptions(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },

        validateStatus: (statusCode){
          if(statusCode == null){
            return false;
          }
          if(statusCode == 422){ // your http status code
            return true;
          }else{
            return statusCode >= 200 && statusCode < 300;
          }
        },
      )
  );

  void onSuccess(Map<String, dynamic> result);
  void onError(String e);

  Future<Map<String, dynamic>?> execute() async {

    var accessToken = await getAccessToken();
    dio.options.headers["Authorization"] = "$accessToken";

    var apiCall = createRequest();
    try {
      Response response = await apiCall;

      if(response.statusCode! >= 200 && response.statusCode! <= 300){
        onSuccess(response.data);
      }

      return response.data;
    } on DioException catch (e) {
      onError(e.error.toString());
    }
    return null;
  }

  Future<Response> createRequest();
}

class OnCompleteListener {
  Function(Map<String, dynamic> json) onResponse;
  Function(DioException) onError;
  OnCompleteListener({required this.onResponse, required this.onError});
}


