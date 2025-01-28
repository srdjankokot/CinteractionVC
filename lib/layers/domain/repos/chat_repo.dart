import 'dart:io';
import 'dart:typed_data';

import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chat_details.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/send_message.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/io/network/models/participant.dart';
import '../../../core/util/util.dart';
import '../../data/dto/chat/chat_dto.dart';
import '../entities/chat_message.dart';

abstract class ChatRepo {
  const ChatRepo();

  Future<void> initialize();
  Future<void> sendMessage(String msg, int participiantId);
  Stream<List<Participant>> getParticipantsStream();
  Stream<List<UserDto>> getUsersStream();
  Stream<List<ChatDto>> getChatsStream();
  Stream<List<ChatMessage>> getMessageStream();
  Stream<ChatDetailsDto> getChatDetailsStream();

  Future<void> sendMessageToChatWrapper(int? chatId, String messageContent,
      int senderId, List<int> participantIds,
      {List<File>? uploadedFiles});
  Future<void> setCurrentParticipant(UserDto user);
  Future<void> setCurrentChat(ChatDto chat);
  Future<void> getChatDetails(int id);
  Future<void> getChatDetailsByParticipiant(int id);
  Future<void> getEmptyChat();
  Future<void> deleteMessage(int id);
  Future<void> editMessage(int id, String message);
  Future<void> messageSeen(int index);

  // Future<void> makeCall(String user);
  // Future<void> answerCall();
  // Future<void> rejectCall();
  // Stream<String> getVideoCallStream();
  // Stream<StreamRenderer> getLocalStream();
  // Stream<StreamRenderer> getRemoteStream();

  Future<void> sendFile(String name, Uint8List bytes);
  Future<void> chooseFile();
  Future<void> leaveRoom();
}
