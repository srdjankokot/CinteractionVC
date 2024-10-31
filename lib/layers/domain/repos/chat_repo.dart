import 'dart:typed_data';

import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/io/network/models/participant.dart';
import '../../../core/util/util.dart';
import '../entities/chat_message.dart';

abstract class ChatRepo{
  const ChatRepo();

  Future<void> initialize();
  Future<void> sendMessage(String msg);
  Stream<List<Participant>> getParticipantsStream();
  Stream<List<UserDto>> getUsersStream();
  Stream<List<ChatMessage>> getMessageStream();
  Future<void> setCurrentParticipant(UserDto user);
  Future<void> messageSeen(int index);

  Future<void> makeCall(String user);
  Future<void> answerCall();
  Future<void> rejectCall();
  Stream<String> getVideoCallStream();
  Stream<StreamRenderer> getLocalStream();
  Stream<StreamRenderer> getRemoteStream();

  Future<void> sendFile(String name, Uint8List bytes);
  Future<void> chooseFile();
}