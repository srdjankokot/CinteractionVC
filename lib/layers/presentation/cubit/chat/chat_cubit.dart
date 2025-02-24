import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:file_picker/file_picker.dart';
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
    chatUseCases.getPaginationStream().listen(_onPagination);
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
        isInitial: true,
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

  void _onPagination(ChatPagination pagination) {
    emit(state.copyWith(pagination: pagination));
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

  ///Updated because of pagination on scroll///
  void _onChats(List<ChatDto> newChats) {
    List<ChatDto> updatedChats = List.from(state.chats ?? []);
    for (var chat in newChats) {
      if (!updatedChats.any((c) => c.id == chat.id)) {
        updatedChats.add(chat);
      }
    }
    emit(state.copyWith(
      isLoading: false,
      chats: updatedChats,
    ));
  }

  void _onChatDetails(ChatDetailsDto chatDetails) {
    emit(state.copyWith(
      isLoading: false,
      chatDetails: chatDetails,
    ));
  }

  Future<void> sendMessage(String msg, List<String> participantIds) async {
    chatUseCases.sendMessage(msg: msg, participantIds: participantIds);
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

  Future<void> openDownloadMedia(int id, String fileName) async {
    chatUseCases.downloadMedia(id, fileName);
  }

  Future<void> loadChats(int page, int paginate) async {
    print('CalledFunc');
    try {
      final chats = await chatUseCases.loadChats(page, paginate);
      // emit(state.copyWith(chats: chats));
    } catch (e) {
      print("Error loading chats: $e");
    }
  }

  Future<void> deleteChat(int id) async {
    try {
      //Updated becasue of pagination on scroll//
      List<ChatDto> updatedChats = List.from(state.chats ?? []);
      updatedChats.removeWhere((chat) => chat.id == id);
      emit(state.copyWith(chats: updatedChats));
      await chatUseCases.deleteChat(id);
    } catch (e) {
      print("❌ Error delete chat: $e");
    }
  }

  Future<void> getChatDetails(int? chatId) async {
    try {
      final chatDetails = await chatUseCases.getChatDetails(chatId!);
      emit(state.copyWith(chatDetails: chatDetails, isLoading: true));
    } catch (e) {
      print("Error fetching chat details: $e");
    }
  }

  Future<void> getChatDetailsByParticipiant(int participiantId) async {
    try {
      final chatDetails =
          await chatUseCases.getChatDetailsByParticipiant(participiantId);
      emit(state.copyWith(chatDetails: chatDetails, isLoading: true));
    } catch (e) {
      print("Error while fetching chat by participiant: $e");
    }
  }

  Future<void> deleteChatMessage(int msgId, int chatId) async {
    chatUseCases.chatDeleteMessage(msgId);
    final chatDetails = await chatUseCases.getChatDetails(chatId);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> editChatMessage(int msgId, String message, int chatId) async {
    chatUseCases.chatEditMessage(msgId, message);
    final chatDetails = await chatUseCases.getChatDetails(chatId);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> removeUserFromGroup(int chatId, int userId) async {
    chatUseCases.removeUserFromGroup(chatId, userId);
    final chatDetails = await chatUseCases.getChatDetails(chatId);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> addUserToGroupChat(
      int chatId, int userId, List<int> participantIds) async {
    chatUseCases.addUserToGroup(chatId, userId, participantIds);
    final chatDetails = await chatUseCases.getChatDetails(chatId);
    emit(state.copyWith(chatDetails: chatDetails));
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
      {required String messageContent,
      List<PlatformFile>? uploadedFiles}) async {
    var participiansList =
        state.chatDetails!.chatParticipants.map((data) => data.id).toList();

    chatUseCases.sendMessageToChatStream(
        chatId: state.chatDetails?.chatId,
        messageContent: messageContent,
        participantIds: participiansList,
        senderId: state.chatDetails!.authUser.id,
        uploadedFiles: uploadedFiles);
  }

  void _onVideoCall(Result result) {
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
