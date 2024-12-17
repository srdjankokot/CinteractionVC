import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:janus_client/janus_client.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/util/util.dart';
import '../../../data/dto/user_dto.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/usecases/call/call_use_cases.dart';
import '../../../domain/usecases/chat/chat_usecases.dart';

class ChatCubit extends Cubit<ChatState> with BlocLoggy {
  final ChatUseCases chatUseCases;
  final CallUseCases callUseCases;

  ChatCubit({required this.chatUseCases, required this.callUseCases})
      : super(const ChatState.initial()) {
    print("Chat Cubit is created");
    _load();
  }

  void _load() async {
    await chatUseCases.chatInitialize();
    await callUseCases.initialize();

    chatUseCases.getParticipantsStream().listen(_onParticipants);
    chatUseCases.getUsersStream().listen(_onUsers);
    chatUseCases.getChatsStream().listen(_onChats);
    chatUseCases.getMessageStream().listen(_onMessages);
    chatUseCases.getChatDetailsStream().listen(_onChatDetails);

    callUseCases.videoCallStream().listen(_onVideoCall);
    callUseCases.getLocalStream().listen(_onLocalStream);
    callUseCases.getRemoteStream().listen(_onRemoteStream);
  }

  @override
  Future<void> close() {
    print('Cubit is being disposed');
    return super.close();
  }

  void _onMessages(List<ChatMessage> messages) {
    var unread = messages.length;
    emit(state.copyWith(
        isInitial: false,
        messages: messages,
        numberOfParticipants: Random().nextInt(10000),
        unreadMessages: unread));
  }

  void _onLocalStream(StreamRenderer localStream) {
    emit(state.copyWith(localStream: localStream));
  }

  void _onRemoteStream(StreamRenderer remoteStream) {
    emit(state.copyWith(
        remoteStream: remoteStream,
        numberOfParticipants: Random().nextInt(10000)));

    print('remote stream changed');
  }

  void _onParticipants(List<Participant> participants) {
    emit(state.copyWith(
        isInitial: false,
        participants: participants,
        numberOfParticipants: Random().nextInt(10000)));
  }

  void _onUsers(List<UserDto> users) {
    print("_onUsers ${users.length}");
    emit(state.copyWith(
        isInitial: false,
        users: users,
        numberOfParticipants: Random().nextInt(10000)));
  }

  void _onChats(List<ChatDto> chats) {
    print("_onChats: $chats ");
    emit(state.copyWith(chats: chats));
  }

  void _onChatDetails(ChatDetailsDto chatDetails) {
    print("onMessages $chatDetails");
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> sendMessage(String msg) async {
    chatUseCases.sendMessage(msg: msg);
  }

  // Future<void> sendMessageToUser(int senderId, String message, int participiantId ) {

  // }

  Future<void> setCurrentParticipant(UserDto user) async {
    chatUseCases.setCurrentParticipant(user);
    emit(state.copyWith(currentParticipant: user));
  }

  Future<void> setCurrentChat(ChatDto chat) async {
    chatUseCases.setCurrentChat(chat);
    emit(state.copyWith(currentChat: chat));
  }

  Future<void> getChatDetails(int chatId) async {
    emit(state.copyWith(isLoading: true));

    try {
      final chatDetails = await chatUseCases.getChatDetails(chatId);
      emit(state.copyWith(chatDetails: chatDetails));
    } catch (e) {
      print("Error fetching chat details: $e");
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> chatMessageSeen(int index) async {
    chatUseCases.messageSeen(index: index);
  }

  Future<void> sendFile(String name, Uint8List bytes) async {
    chatUseCases.sendFile(name, bytes);
  }

  Future<void> chooseFile() async {
    chatUseCases.chooseFile();
  }

  Future<void> sendChatMessage(
      chatId, messageContent, participiantsId, senderId) async {
    chatUseCases.sendMessageToChatStream(
        chatId: chatId,
        messageContent: messageContent,
        participantIds: participiantsId,
        senderId: senderId);
  }

  void _onVideoCall(Result result) {
    print(result.event);
    print(result.username);
    if (result.event == "incomingcall") {
      ;
      emit(state.copyWith(
          incomingCall: true,
          caller: state.users
              ?.firstWhere((element) => element.id == result.username)
              .name));
    }
    if (result.event == "calling") {
      emit(state.copyWith(calling: true));
    }

    if (result.event == "accepted") {
      emit(state.copyWith(calling: false, incomingCall: false));
    }

    if (result.event == "rejected") {
      print("change state to non call");
      emit(state.callFinished());
    }
  }

  Future<void> makeCall(String toUser) async {
    callUseCases.makeCall(toUser: toUser);
  }

  Future<void> answerCall() async {
    callUseCases.answerCall();
    emit(state.callFinished());
  }

  Future<void> rejectCall() async {
    callUseCases.rejectCall("click button");
    // emit(state.callFinished());
  }

  Future<void> audioMute() async {
    var mute = state.audioMuted;
    await callUseCases.mute(kind: 'audio', muted: !mute);
    emit(state.copyWith(audioMuted: !mute));
  }

  Future<void> videoMute() async {
    var mute = state.videoMuted;
    await callUseCases.mute(kind: 'video', muted: !mute);
    emit(state.copyWith(videoMuted: !mute));
  }

  void changeListType(ListType listType) {
    emit(state.copyWith(listType: listType));
  }
}
