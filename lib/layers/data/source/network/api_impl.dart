import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/io/network/models/login_response.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';
import 'package:dio/dio.dart';

import '../../../../core/io/network/urls.dart';

class ApiImpl extends Api {
  T? _parseResponseData<T>(
      dynamic data, T Function(Map<String, dynamic> json) fromJson) {
    return fromJson(data);
  }

  void _parseException(e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      print(e.response?.data);
      print(e.response?.headers);
      print(e.response?.requestOptions);

      //  API responds with 404 when reached the end
      if (e.response?.statusCode == 404) return null;
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print(e.requestOptions);
      print(e.message);
    }
  }

  @override
  Future<LoginResponse?> signInEmailPass({required email, required pass}) async {
    try {
      var formData = FormData.fromMap({'email': email, 'password': pass});
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.post(Urls.loginEndpoint, data: formData);
      LoginResponse? login = _parseResponseData(response.data, LoginResponse.fromJson);

      return login;
      // return login;
    } on DioException catch (e) {
      _parseException(e);
    }
    return null;
  }

  @override
  Future<LoginResponse?> getMeetings() {
    // TODO: implement getMeetings
    throw UnimplementedError();
  }

  @override
  Future<LoginResponse?> startCallHandler(
      {required streamId,
      required timezone,
      required recording,
      required userId}) {
    // TODO: implement startCallHandler
    throw UnimplementedError();
  }

  @override
  Future<UserDto?> getUserDetails() async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get(Urls.getUserDetails);
      print(response);
      return _parseResponseData(response.data, UserDto.fromJson);
    } on DioException catch (e) {
      _parseException(e);
    }
    return null;
  }

  @override
  Future<String?> socialLogin({required provider, required token}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = FormData.fromMap({'provider': provider, 'token': token});
    Response response =
        await dio.post(Urls.socialLoginEndpoint, data: formData);
    var accessToken = response.data['Access-Token'] as String;


    return accessToken;
  }

  @override
  Future<double?> engagement(
      {required averageAttention,
      required callId,
      required image,
      required participantId}) async {

    var formData = {
      'average_attention': 0,
      'call_id': callId,
      'current_attention': 0,
      'image': image,
      "participant_id": participantId
    };

    Dio dio = await getIt.getAsync<Dio>();
    try{
      dio.options.headers['Authorization'] = Urls.IVIAccessToken;
      var response = await dio.post(Urls.engagement, data: formData);

      return response.data['engagements'][0]['engagement_rank'];

      // {"engagements":[{"call_id":1473,"engagement_rank":0.8191,"participant_id":36}]}
    }
    on  DioException catch (e, s){
      print(e);
    }


    return 0;
  }


  @override
  Future<int?> startCall({required streamId, required userId}) async{
    Dio dio = await getIt.getAsync<Dio>();


    var formData = {'streamId': streamId, 'user_id': userId, 'timezone': 'Europe/Belgrade', 'recording' : false};

    Response response = await dio.post(Urls.startCall, data: formData);
    var callId = response.data['call_id'] as int;

    return callId;
  }

  @override
  Future<bool> endCall({required callId, required userId}) async{
    Dio dio = await getIt.getAsync<Dio>();

    var formData = FormData.fromMap({'call_id': callId, 'user_id': userId});
    Response response = await dio.post(Urls.endCall, data: formData);

    return response.statusCode == 200;
  }


}
