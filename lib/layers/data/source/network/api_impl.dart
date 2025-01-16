import 'dart:async';
import 'dart:io';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/io/network/models/login_response.dart';
import 'package:cinteraction_vc/layers/data/dto/api_error_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/dashboard_response.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/io/network/urls.dart';
import '../../../domain/entities/api_response.dart';
import '../../dto/chat/chat_dto.dart';
import '../../dto/dashboard/dashboard_response_dto.dart';
import '../../dto/meetings/meeting_dto.dart';
import '../../dto/meetings/meeting_response_dto.dart';

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
      return ApiResponse(
          response: _parseResponseData(response.data, UserDto.fromJson));
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<List<UserDto>>> getCompanyUsers() async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get(Urls.getCompanyUsers);

      List<UserDto> users = [];
      for (var u in response.data['data']) {
        var user = UserDto.fromJson(u as Map<String, dynamic>);
        users.add(user);
      }

      return ApiResponse(response: users);
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
  Future<double?> getEngagement(
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
      return double.parse(
          response.data['engagements'][0]['engagement_rank'].toString());
      return -1;
    } on DioException catch (e, s) {
      print(e);
    } on Exception catch (e) {
      print(e);
    }
    return 0;
  }

  @override
  Future<ApiResponse<int>> startCall(
      {required streamId, required userId}) async {
    Dio dio = await getIt.getAsync<Dio>();
    print('UserId: $userId');
    try {
      var formData = {
        'stream_id': streamId,
        'user_id': int.parse(userId.toString().replaceAll("hash_", '')),
        'timezone': 'Europe/Belgrade',
        'recording': false
      };

      print(formData);
      Response response = await dio.post(Urls.startCall, data: formData);
      var callId = response.data['meeting_id'] as int;
      print('callId $callId');

      return ApiResponse(response: callId);
      // return login;
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<bool> endCall({required callId, required userId}) async {
    Dio dio = await getIt.getAsync<Dio>();
    var userIds = int.parse(userId.toString().replaceAll("hash_", ''));
    var formData = FormData.fromMap({
      'meeting_id': callId,
      'user_id': userIds,
    });
    Response response = await dio.post(
      Urls.endCall(callId, userIds), // Dinamički generisan URL
      data: formData,
    );
    print('end call by user $response');

    return response.statusCode == 200;
  }

  @override
  Future<ApiResponse<MeetingResponseDto>> getMeetings(int page) async {
    Dio dio = await getIt.getAsync<Dio>();
    try {
      Response response = await dio.get('${Urls.meetings}$page');

      List<MeetingDto> meetings = [];

      for (var par in response.data['data']) {
        var participant = MeetingDto.fromJson(par as Map<String, dynamic>);
        meetings.add(participant);
      }

      // var lastPage = response.data['last_page'];

      return ApiResponse(response: MeetingResponseDto.fromJson(response.data));
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<List<MeetingDto>?>> getScheduledMeetings() async {
    Dio dio = await getIt.getAsync<Dio>();
    try {
      Response response = await dio.get(Urls.scheduledMeetings);
      List<MeetingDto> meetings = [];
      for (var meet in response.data['data']) {
        var meeting = MeetingDto.fromJson(meet as Map<String, dynamic>);
        meetings.add(meeting);
      }
      return ApiResponse(response: meetings);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<MeetingDto?>> getNextMeeting() async {
    Dio dio = await getIt.getAsync<Dio>();
    try {
      Response response = await dio.get(Urls.nextScheduledMeetings);
      MeetingDto? nextMeeting;
      for (var meet in response.data['data']) {
        var meeting = MeetingDto.fromJson(meet as Map<String, dynamic>);
        if (DateTime.now().difference(meeting.meetingStart).abs() <
            const Duration(hours: 24)) {
          nextMeeting = meeting;
          break;
        }
      }

      return ApiResponse(response: nextMeeting);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
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
      // 'terms': terms
    };

    try {
      Response response = await dio.post(Urls.registerEndpoint, data: formData);
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<String?>> scheduleMeeting(
      {required String name,
      required String description,
      required String tag,
      required DateTime date}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = {
      'name': name,
      'description': description,
      'tag': tag,
      'startDateTime': DateFormat('yyyy-MM-dd HH:mm').format(date),
      'localTimeZone': 'Europe/Belgrade'
    };

    print(DateFormat('yyyy-MM-dd HH:mm').format(date));

    try {
      Response response = await dio.post(Urls.scheduleMeeting, data: formData);
      print(response);
      return ApiResponse(response: response.data['link']);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool>> sendEngagement(
      {required engagement, required userId, required callId}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = {
      'attention': engagement,
      'user_id': userId,
      'call_id': callId,
    };

    try {
      Response response = await dio.post(Urls.sendEngagement, data: formData);
      print(response);
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool?>> sendMessage(
      {required String userId,
      required String message,
      required String callId}) {
    // TODO: implement sendMessage
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<DashboardResponseDto?>> getDashboardData() async {
    Dio dio = await getIt.getAsync<Dio>();

    try {
      Response response = await dio.get(Urls.dashboard);
      // print(response.data);
      var dashboard =
          DashboardResponseDto.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(response: dashboard);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool>> resetPassword({required email}) async {
    // https://vc.cinteraction.com/api/forgot-password
    // Method: POST
    // Header:
    // Accept: application/json
    // Body:
    // email

    Dio dio = await getIt.getAsync<Dio>();
    var formData = {
      'email': email,
    };
    try {
      Response response = await dio.post(Urls.restPassword, data: formData);
      print(response);
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool>> setNewPassword(
      {required email, required token, required newPassword}) async {
    Dio dio = await getIt.getAsync<Dio>();

    var formData = {
      'email': email,
      'token': token,
      'password': newPassword,
      'password_confirmation': newPassword
    };
    try {
      Response response = await dio.post(Urls.setNewPassword, data: formData);
      print(response);
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<bool>> sentChatMessage(
      {required text, required from, required to}) async {
    Dio dio = await getIt.getAsync<Dio>();
    var formData = {'text': text, 'from': from, 'to': to};
    try {
      Response response = await dio.post(Urls.sentMessage, data: formData);
      print("ChatMessageToServer $response");
      return ApiResponse(
          response: response.statusCode! > 200 && response.statusCode! < 300);
    } on DioException catch (e, s) {
      print(e.response?.statusMessage);
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<List<ChatDto>>> getAllChats() async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get(Urls.getAllChats);
      List<ChatDto> chats = [];
      for (var chat in response.data['data']) {
        var chatDto = ChatDto.fromJson(chat as Map<String, dynamic>);
        chats.add(chatDto);
        print('chats $chatDto[chat_id]');
      }

      return ApiResponse(response: chats);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> getChatById({dynamic id}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get('${Urls.getChatById}$id');
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> getChat() async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get(Urls.getChatById);
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> getChatByParticipiant(
      {required dynamic id}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get('${Urls.getChatByParticipiant}$id');
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> deleteMessageById(
      {required dynamic id}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.delete('${Urls.deleteMessageById}$id');
      var chatDetails = ChatDetailsDto.fromJson(response.data);
      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> editMessageById({
    required int id,
    required String message,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.put(
        '${Urls.editMessage}$id',
        data: {
          'message': message,
        },
      );
      var chatDetails = ChatDetailsDto.fromJson(response.data);
      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<MessageDto>> sendMessageToChat({
    required String name,
    int? chatId,
    required int senderId,
    required String message,
    required List<int> participantIds,
    List<File>? uploadedFiles,
  }) async {
    Dio dio = await getIt.getAsync<Dio>();
    var formData = FormData.fromMap({
      'name': name,
      if (chatId != 0) 'chat_id': chatId,
      'sender_id': senderId,
      'message': message,
      'chat_participants':
          participantIds.map((id) => {'participant_id': id}).toList(),
    });

    try {
      Response response = await dio.post(
        Urls.sentChatMessage,
        data: formData,
      );
      if (response.data != null && response.data['messages'] != null) {
        var messages = response.data['messages'] as List;
        var mappedMessages =
            messages.map((msg) => MessageDto.fromJson(msg)).toList();
        if (mappedMessages.isNotEmpty) {
          return ApiResponse(response: mappedMessages.first);
        }
      }
      var messageDto = MessageDto.fromJson(response.data);
      return ApiResponse(response: messageDto);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }
}
