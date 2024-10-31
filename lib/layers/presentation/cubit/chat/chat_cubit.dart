import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/util/util.dart';
import '../../../data/dto/user_dto.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/usecases/chat/chat_usecases.dart';

class ChatCubit extends Cubit<ChatState> with BlocLoggy {
  // final int roomId;
  // final String displayName;
  final ChatUseCases chatUseCases;

  // StreamSubscription<List<Participant>>? _participantsStream;

  ChatCubit({required this.chatUseCases}) : super(const ChatState.initial()) {
    print("Chat Cubit is created");
    _load();
  }

  void _load() async {
    await chatUseCases.chatInitialize();
    chatUseCases.getParticipantsStream().listen(_onParticipants);
    chatUseCases.getUsersStream().listen(_onUsers);
    chatUseCases.getMessageStream().listen(_onMessages);
    chatUseCases.videoCallStream().listen(_onVideoCall);
    chatUseCases.getLocalStream().listen(_onLocalStream);
    chatUseCases.getRemoteStream().listen(_onRemoteStream);
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
    print("_onRemoteStream");
    emit(state.copyWith(remoteStream: remoteStream));
  }

  void _onParticipants(List<Participant> participants) {
    emit(state.copyWith(
        isInitial: false,
        participants: participants,
        numberOfParticipants: Random().nextInt(10000)));
  }

  void _onUsers(List<UserDto> users) {
    print("User list ${users.length}");
    emit(state.copyWith(
        isInitial: false,
        users: users,
        numberOfParticipants: Random().nextInt(10000)));
  }

  Future<void> sendMessage(String msg) async {
    chatUseCases.sendMessage(msg: msg);
  }

  Future<void> setCurrentParticipant(UserDto user) async {
    chatUseCases.setCurrentParticipant(user);
    emit(state.copyWith(currentParticipant: user));
  }

  Future<void> chatMessageSeen(int index) async {
    chatUseCases.messageSeen(index: index);
  }

  Future<void> sendFile(String name, Uint8List bytes) async
  {
    chatUseCases.sendFile(name, bytes);
  }

  Future<void> chooseFile() async
  {
    chatUseCases.chooseFile();
  }

  void _onVideoCall(String action) {
    print(action);
    if (action == "IncomingCall") {
      emit(state.copyWith(incomingCall: true));
    }
    if(action == "Calling")
      {
        emit(state.copyWith(calling: true));
      }

    if(action == "Rejected")
      {
        print("change state to non call");
        emit(state.callFinished());

      }
  }

  Future<void> makeCall(String toUser) async {
    chatUseCases.makeCall(toUser: toUser);
  }

  Future<void> answerCall() async {
    chatUseCases.answerCall();
    emit(state.callFinished());

  }

  Future<void> rejectCall() async {
    chatUseCases.rejectCall();
    emit(state.callFinished());
  }
}
