import '../../../core/io/network/models/login_response.dart';
import '../../data/dto/user_dto.dart';

abstract class Api {
  Future<LoginResponse?> signInEmailPass({required email, required pass});
  Future<String?> socialLogin({required provider, required token});
  Future<UserDto?> getUserDetails();
  Future<LoginResponse?> getMeetings();
  Future<LoginResponse?> startCallHandler({required streamId, required timezone, required recording, required userId});


  Future<double?> engagement({required averageAttention, required callId, required image, required participantId});

  Future<int?> startCall({required streamId, required userId});
  Future<bool> endCall({required callId, required userId});
}