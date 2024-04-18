import 'dart:convert';
import 'dart:html';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/io/network/models/login_response.dart';
import 'package:cinteraction_vc/core/navigation/router.dart';
import 'package:cinteraction_vc/layers/data/dto/api_error_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/io/network/urls.dart';
import '../../../domain/entities/api_response.dart';
import '../../dto/meeting_dto.dart';

class ApiImpl extends Api {
  T? _parseResponseData<T>(
      dynamic data, T Function(Map<String, dynamic> json) fromJson) {
    return fromJson(data);
  }

  @override
  Future<ApiResponse<LoginResponse?>> signInEmailPass(
      {required email, required pass}) async {
    try {
      var formData = FormData.fromMap({'email': email, 'password': pass});
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.post(Urls.loginEndpoint, data: formData);
      LoginResponse? login =
      _parseResponseData(response.data, LoginResponse.fromJson);

      return ApiResponse(response: login);
      // return login;
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }
  @override
  Future<ApiResponse<UserDto?>> getUserDetails() async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get(Urls.getUserDetails);
      print(response);
      return ApiResponse(response: _parseResponseData(response.data, UserDto.fromJson));
    } on DioException catch (e) {
     return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
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
    try {
      dio.options.headers['Authorization'] = Urls.IVIAccessToken;
      var response = await dio.post(Urls.engagement, data: formData);

      return response.data['engagements'][0]['engagement_rank'];

    } on DioException catch (e, s) {
      print(e);
    }

    return 0;
  }

  @override
  Future<ApiResponse<int>> startCall({required streamId, required userId}) async {
    Dio dio = await getIt.getAsync<Dio>();
    try {
      var formData = {
        'streamId': streamId,
        'user_id': userId,
        'timezone': 'Europe/Belgrade',
        'recording': false
      };

      Response response = await dio.post(Urls.startCall, data: formData);
      var callId = response.data['call_id'] as int;

      return ApiResponse(response: callId);
      // return login;
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }

  }

  @override
  Future<bool> endCall({required callId, required userId}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = FormData.fromMap({'call_id': callId, 'user_id': userId});
    Response response = await dio.post(Urls.endCall, data: formData);

    return response.statusCode == 200;
  }

  @override
  Future<List<MeetingDto>?> getMeetings() async {
    Dio dio = await getIt.getAsync<Dio>();
    Response response = await dio.get(Urls.meetings);

    List<MeetingDto> meetings = [];

    for (var par in response.data['data']) {
      var participant = MeetingDto.fromJson(par as Map<String, dynamic>);
      meetings.add(participant);
    }

    // PastMeetingResponseDto? responseDto = _parseResponseData(response.data, PastMeetingResponseDto.fromJson);

    return meetings;
  }

  @override
  Future<ApiResponse<bool>> signUpEmailPass(
      {required email, required pass, required name, required terms}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = {
      'name': name,
      'email': email,
      'password': pass,
      'password_confirmation': pass,
      'terms': terms
    };

    try {
      Response response = await dio.post(Urls.registerEndpoint, data: formData);
      return ApiResponse(response: response.statusCode! > 200 && response.statusCode! < 300);

    } on DioException catch (e, s) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }

  }
}




