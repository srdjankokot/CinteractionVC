import 'package:cinteraction_vc/layers/data/dto/meeting_dto.dart';

import '../../../core/io/network/models/login_response.dart';
import '../../data/dto/user_dto.dart';
import '../entities/api_response.dart';

abstract class Api {
  Future<ApiResponse<LoginResponse?>> signInEmailPass({required email, required pass});
  Future<ApiResponse<bool>> signUpEmailPass({required email, required pass, required name, required terms});
  Future<String?> socialLogin({required provider, required token});
  Future<ApiResponse<UserDto?>> getUserDetails();

  Future<double?> getEngagement({required averageAttention, required callId, required image, required participantId});
  Future<ApiResponse<bool>> sendEngagement({required engagement, required userId, required callId});

  Future<ApiResponse<int>> startCall({required streamId, required userId});
  Future<bool> endCall({required callId, required userId});

  Future<List<MeetingDto>?> getMeetings();
  Future<ApiResponse<List<MeetingDto>?>> getScheduledMeetings();
  Future<ApiResponse<MeetingDto?>> getNextMeeting();

  Future<ApiResponse<bool?>> scheduleMeeting({required String name, required String description, required String tag, required DateTime date});

  Future<ApiResponse<bool?>> sendMessage({required String userId, required String message, required String callId});

}