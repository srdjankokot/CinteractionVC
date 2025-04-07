import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:cinteraction_vc/layers/data/repos/chat_repo_impl.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../../core/janus/janus_client.dart';
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

  final bool isInCallChat;
  bool isLoaded = false;

  ChatCubit(
      {required this.chatUseCases,
      required this.callUseCases,
      required this.isInCallChat})
      : super(const ChatState.initial()) {
    print("Chat Cubit is created");
    if (!isInCallChat) load(isInCallChat, 1234);
  }

  void load(bool isInCall, int roomId) async {
    if (!isLoaded) {
      await chatUseCases.chatInitialize(
          isInCall: isInCall, chatGroupId: roomId);
      if (!isInCall) {
        await callUseCases.initialize();
      } else {
        setCurrentChat(ChatDto(id: roomId, name: "name", chatGroup: true));
        getChatDetails(roomId, 1);
      }

      chatUseCases.getParticipantsStream().listen(_onParticipants);
      chatUseCases.getUsersStream().listen(_onUsers);
      chatUseCases.getChatsStream().listen(_onChats);
      chatUseCases.getMessageStream().listen(_onMessages);
      chatUseCases.getChatDetailsStream().listen(_onChatDetails);
      chatUseCases.getPaginationStream().listen(_onPagination);
      chatUseCases.getUsersPaginationStream().listen(_onUsersPagination);

      if (!isInCall) {
        callUseCases.videoCallStream().listen(_onVideoCall);
        callUseCases.getLocalStream().listen(_onLocalStream);
        callUseCases.getRemoteStream().listen(_onRemoteStream);
      }

      isLoaded = true;
      print("inCall chat loaded: $isInCall");
    }
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

  void _onUsersPagination(UserListResponse userPagination) {
    emit(state.copyWith(usersPagination: userPagination));
  }

  void _onParticipants(List<Participant> participants) {
    emit(state.copyWith(
        isInitial: false,
        participants: participants,
        numberOfParticipants: Random().nextInt(10000)));
  }

  void _onUsers(List<UserDto> newUsers) {
    List<UserDto> updatedUsers = List.from(state.users ?? []);

    for (var user in newUsers) {
      int existingIndex = updatedUsers.indexWhere((u) => u.id == user.id);

      if (existingIndex != -1) {
        updatedUsers[existingIndex] = updatedUsers[existingIndex].copyWith(
          name: user.name,
          email: user.email,
          online: user.online,
        );
      } else {
        updatedUsers.add(user);
      }
    }

    emit(state.copyWith(
      isInitial: false,
      users: updatedUsers,
      numberOfParticipants: Random().nextInt(10000),
    ));
  }

  void _onChats(List<ChatDto> newChats) {
    List<ChatDto> updatedChats = List.from(state.chats ?? []);

    for (var chat in newChats) {
      int existingIndex = updatedChats.indexWhere((c) => c.id == chat.id);

      if (existingIndex != -1) {
        updatedChats[existingIndex] = updatedChats[existingIndex].copyWith(
          lastMessage: chat.lastMessage,
          isOnline: chat.isOnline,
        );
      } else {
        updatedChats.add(chat);
      }
      if (state.currentChat?.id == chat.id) {
        emit(state.copyWith(
          currentChat: state.currentChat!.copyWith(isOnline: chat.isOnline),
        ));
      }

      emit(state.copyWith(
        isLoading: false,
        chats: updatedChats,
      ));
    }
  }

  void _onChatDetails(ChatDetailsDto chatDetails) {
    bool isPaginationActive =
        (chatDetails.messages.meta?['current_page'] ?? 1) > 1;

    if (!isPaginationActive) {
      emit(state.copyWith(
        isInitialLoading: false,
        chatDetails: chatDetails,
      ));
      return;
    }

    List<MessageDto> updatedMessages =
        List.from(state.chatDetails!.messages.messages);

    for (var newMessage in chatDetails.messages.messages) {
      int existingIndex =
          updatedMessages.indexWhere((m) => m.id == newMessage.id);

      if (existingIndex != -1) {
        updatedMessages[existingIndex] = newMessage;
      } else {
        updatedMessages.insert(0, newMessage);
      }
    }

    emit(state.copyWith(
      chatDetails: state.chatDetails!.copyWith(
        messages: state.chatDetails!.messages.copyWith(
          messages: updatedMessages,
          links: chatDetails.messages.links,
          meta: chatDetails.messages.meta,
        ),
      ),
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
    try {
      final chats = await chatUseCases.loadChats(page, paginate);
      // emit(state.copyWith(chats: chats));
    } catch (e) {
      print("Error loading chats: $e");
    }
  }

  Future<void> loadUsers(int page, int paginate) async {
    try {
      final users = await chatUseCases.loadUsers(page, paginate);
    } catch (e) {
      print('Error loading users: $e');
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

  Future<void> getChatDetails(int? chatId, int page) async {
    try {
      final chatDetails = await chatUseCases.getChatDetails(chatId!, page);
      bool isNewChat = state.chatDetails?.chatId != chatId;
      emit(state.copyWith(
          chatDetails: chatDetails, isInitialLoading: isNewChat));
    } catch (e) {
      print("Error fetching chat details: $e");
    }
  }

  Future<void> getChatDetailsByParticipiant(
      int participiantId, int page) async {
    try {
      final chatDetails =
          await chatUseCases.getChatDetailsByParticipiant(participiantId, page);
      emit(state.copyWith(chatDetails: chatDetails, isInitialLoading: true));
    } catch (e) {
      print("Error while fetching chat by participiant: $e");
    }
  }

  Future<void> deleteChatMessage(int msgId, int chatId, int page) async {
    chatUseCases.chatDeleteMessage(msgId);
    final chatDetails = await chatUseCases.getChatDetails(chatId, page);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> editChatMessage(
      int msgId, String message, int chatId, int page) async {
    chatUseCases.chatEditMessage(msgId, message);
    final chatDetails = await chatUseCases.getChatDetails(chatId, page);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> removeUserFromGroup(int chatId, int userId, int page) async {
    chatUseCases.removeUserFromGroup(chatId, userId);
    final chatDetails = await chatUseCases.getChatDetails(chatId, page);
    emit(state.copyWith(chatDetails: chatDetails));
  }

  Future<void> addUserToGroupChat(
      int chatId, int userId, List<int> participantIds, int page) async {
    chatUseCases.addUserToGroup(chatId, userId, participantIds);
    final chatDetails = await chatUseCases.getChatDetails(chatId, page);
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

  Future<void> leaveRoom() async {
    chatUseCases.leaveRoom();
  }

  Future<void> sendChatMessage(
      {required String messageContent,
      List<PlatformFile>? uploadedFiles}) async {
    var participiansList = !isInCallChat
        ? state.chatDetails!.chatParticipants.map((data) => data.id).toList()
        : state.participants!.map((data) => data.id).toList();

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
