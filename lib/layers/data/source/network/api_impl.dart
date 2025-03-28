import 'dart:async';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/io/network/models/login_response.dart';
import 'package:cinteraction_vc/layers/data/dto/api_error_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
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

      // clearDioCookies(dio);

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
  Future<ApiResponse<UserListResponse>> getCompanyUsers(
      int page, int paginate) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio
          .get('${Urls.getCompanyUsers}?page=$page&paginate=$paginate');

      var userListResponse = UserListResponse.fromJson(response.data);

      return ApiResponse(response: userListResponse);
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
    var accessToken = response.data['access_token'] as String;

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
  Future<ApiResponse<MeetingDto>> startCall(
      {required streamId, required userId}) async {
    Dio dio = await getIt.getAsync<Dio>();
    print('UserId: $userId');
    try {
      var formData = {
        'stream_id': streamId,
        'user_id': int.parse(userId),
        'timezone': 'Europe/Belgrade',
        'recording': false
      };

      print(formData);
      Response response = await dio.post(Urls.startCall, data: formData);
      var callId = response.data['meeting_id'] as int;
      var chatId = response.data['chat_id'] as int;
      print('callId $callId');

      MeetingDto meetingDto = new MeetingDto(
          callId: callId,
          chatId: chatId,
          organizerId: 0,
          organizer: "",
          meetingStart:  DateTime.parse(response.data['meeting_start'] as String));

      return ApiResponse(response: meetingDto);
      // return login;
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<bool> endCall({required callId, required userId}) async {
    Dio dio = await getIt.getAsync<Dio>();
    var userIds = int.parse(userId);
    var formData = FormData.fromMap({
      'meeting_id': callId,
      'user_id': userIds,
    });
    Response response = await dio.post(
      Urls.endCall(callId, userIds),
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
  Future<ApiResponse<String>> signUpEmailPass(
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
      return ApiResponse(response: response.data["message"]);
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
      'timezone': 'Europe/Belgrade'
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
      // 'user_id': userId,
      // 'call_id': callId,
    };

    try {
      Response response =
          await dio.post('${Urls.sendEngagement}$callId', data: formData);
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
  Future<ApiResponse<ChatPagination>> getAllChats({
    required int page,
    required int paginate,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response =
          await dio.get('${Urls.getAllChats}?page=$page&paginate=$paginate');

      ChatPagination chatPagination =
          ChatPagination.fromJson(response.data as Map<String, dynamic>);

      return ApiResponse(response: chatPagination);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<List<ChatDto>>> deleteChat({required int id}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.delete('${Urls.deleteChat}$id');

      List<ChatDto> chats = [];
      for (var chat in response.data['data']) {
        var chatDto = ChatDto.fromJson(chat as Map<String, dynamic>);
        chats.add(chatDto);
      }
      return ApiResponse(response: chats);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> getChatById(
      {required id, required page}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.get('${Urls.getChatById}$id?page=$page');
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<Uint8List>> downloadMedia({required int id}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response<List<int>> response = await dio.get<List<int>>(
        '${Urls.downloadMedia}$id',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      print('ResponseMedia: $response');

      if (response.data == null) {
        print('There is no file!');
      }

      return ApiResponse(response: Uint8List.fromList(response.data!));
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
      {required int id, required int page}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response =
          await dio.get('${Urls.getChatByParticipiant}$id?page=$page');
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> addUserToGroupChat({
    required int chatId,
    required int userId,
    required List<int> participantIds,
  }) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.post(
        "${Urls.addUserOnGroupChat}$chatId",
        data: {
          "chat_participants":
              participantIds.map((id) => {"participant_id": id}).toList(),
          "user_id": userId,
        },
      );
      var chatDetails = ChatDetailsDto.fromJson(response.data);

      return ApiResponse(response: chatDetails);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }

  @override
  Future<ApiResponse<ChatDetailsDto>> removeUserFromGroupChat(
      {required int chatId, required int userId}) async {
    try {
      Dio dio = await getIt.getAsync<Dio>();
      Response response = await dio.post(
        "${Urls.removeUserFromGroupChat}$chatId",
        data: {"user_id": userId},
      );
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
    String? name,
    int? chatId,
    required int senderId,
    String? message,
    required List<int> participantIds,
    List<PlatformFile>? uploadedFiles,
  }) async {
    Dio dio = await getIt.getAsync<Dio>();

    print('Name $name');

    var formDataMap = {
      'sender_id': senderId,
      'chat_participants':
          participantIds.map((id) => {'participant_id': id}).toList(),
    };

    if (chatId != null) {
      formDataMap['chat_id'] = chatId;
    }

    if (name != null) {
      formDataMap['name'] = name;
    }

    if (message != null && message.trim().isNotEmpty) {
      formDataMap['message'] = message;
    }
    if (uploadedFiles != null && uploadedFiles.isNotEmpty) {
      List<MultipartFile> files = [];

      for (var file in uploadedFiles) {
        if (file.bytes != null) {
          files.add(
            MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
            ),
          );
        }
      }

      formDataMap['uploaded_files'] = files;
    }

    var formData = FormData.fromMap(formDataMap);

    try {
      Response response = await dio.post(
        Urls.sentChatMessage,
        data: formData,
      );

      if (response.data != null &&
          response.data['messages'] is Map<String, dynamic>) {
        final messagesMap = response.data['messages'] as Map<String, dynamic>;

        if (messagesMap.containsKey('data') && messagesMap['data'] is List) {
          final List<MessageDto> parsedMessages = (messagesMap['data']
                  as List<dynamic>)
              .map((msg) => MessageDto.fromJson(msg as Map<String, dynamic>))
              .toList();
          if (parsedMessages.isNotEmpty) {
            return ApiResponse(response: parsedMessages.first);
          }
        }
      }
      var messageDto = MessageDto.fromJson(response.data);
      return ApiResponse(response: messageDto);
    } on DioException catch (e) {
      return ApiResponse(error: ApiErrorDto.fromDioException(e));
    }
  }
}
