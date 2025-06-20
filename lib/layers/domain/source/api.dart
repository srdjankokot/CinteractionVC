import 'dart:io';
import 'dart:typed_data';

import 'package:cinteraction_vc/layers/data/dto/meetings/meeting_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/dashboard_response.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/io/network/models/login_response.dart';
import '../../data/dto/chat/chat_detail_dto.dart';
import '../../data/dto/chat/chat_dto.dart';
import '../../data/dto/user_dto.dart';
import '../entities/api_response.dart';
import '../entities/meetings/meeting.dart';
import '../entities/meetings/meeting_response.dart';

abstract class Api {
  Future<ApiResponse<LoginResponse?>> signInEmailPass(
      {required email, required pass});
  Future<ApiResponse<String>> signUpEmailPass(
      {required email, required pass, required name, required terms});
  Future<String?> socialLogin({required provider, required token});
  Future<ApiResponse<UserDto?>> getUserDetails();

  Future<double?> getEngagement(
      {required averageAttention,
      required callId,
      required image,
      required participantId});


  Future<double?> getDrowsiness(
      {required averageAttention,
        required callId,
        required image,
        required participantId});



  Future<ApiResponse<bool>> sendEngagement(
      {required engagement, required userId, required callId});

  Future<ApiResponse<MeetingDto>> startCall(
      {required streamId, required userId});
  Future<bool> endCall({required callId, required userId});

  Future<ApiResponse<MeetingResponse?>> getMeetings(int page);
  Future<ApiResponse<List<Meeting>?>> getScheduledMeetings();
  Future<ApiResponse<MeetingDto?>> getNextMeeting();

  Future<ApiResponse<Meeting?>> scheduleMeeting(
      {required String name,
      required String description,
      required String tag,
      required DateTime date,
      required List<String> emails});

  Future<ApiResponse<bool?>> sendMessage(
      {required String userId,
      required String message,
      required String callId});

  Future<ApiResponse<DashboardResponse?>> getDashboardData();

  Future<ApiResponse<bool>> resetPassword({required email});
  Future<ApiResponse<bool>> setNewPassword(
      {required email, required token, required newPassword});

  Future<ApiResponse<bool>> sentChatMessage(
      {required text, required from, required to});

  Future<ApiResponse<UserListResponse>> getCompanyUsers(
      int page, int paginate, String? search);

  Future<ApiResponse<ChatPagination>> getAllChats(
      {required int page, required int paginate, String? search});
  Future<ApiResponse<List<ChatDto>>> deleteChat(
      {required int chatId, required int userId});
  Future<ApiResponse<ChatDetailsDto>> getChatById(
      {required int id, required int page});
  Future<ApiResponse<ChatDetailsDto>> getChat();
  Future<ApiResponse<ChatDetailsDto>> getChatByParticipiant(
      {required int id, required int page});
  Future<ApiResponse<ChatDetailsDto>> deleteMessageById({required int id});
  Future<ApiResponse<Uint8List>> downloadMedia({required int id});
  Future<ApiResponse<ChatDetailsDto>> editMessageById(
      {required int id, required String message});
  Future<ApiResponse<ChatDetailsDto>> removeUserFromGroupChat(
      {required int chatId, required int userId});
  Future<ApiResponse<ChatDetailsDto>> addUserToGroupChat(
      {required int chatId,
      required int userId,
      required List<int> participantIds});
  Future<ApiResponse<MessageDto>> sendMessageToChat({
    required String? name,
    int? chatId,
    required int senderId,
    String? message,
    required List<int> participantIds,
    List<PlatformFile>? uploadedFiles,
    Function(double progress)? onProgress,
  });
  Future<ApiResponse> changeProfileImage(
      {required PlatformFile file, required User user});
  Future<ApiResponse> updateUserProfile({
    PlatformFile? file,
    required User user,
    String? name,
    String? email,
    String? password,
    String? passwordConfirmation,
  });
}
