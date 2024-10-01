import 'dart:async';
import 'dart:math';

import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/chat_message.dart';
import '../../../domain/usecases/chat/chat_usecases.dart';

class ChatCubit extends Cubit<ChatState> with BlocLoggy {
  // final int roomId;
  // final String displayName;
  final ChatUseCases chatUseCases;

  StreamSubscription<List<Participant>>? _participantsStream;

  ChatCubit({required this.chatUseCases}) : super(const ChatState.initial()) {
    print("Chat Cubit is created");
    _load();
  }


  void _load() async {
    await chatUseCases.chatInitialize();
    _participantsStream =
        chatUseCases.getParticipantsStream().listen(_onParticipants);
    chatUseCases.getMessageStream().listen(_onMessages);
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

  void _onParticipants(List<Participant> participants) {
    emit(state.copyWith(
        isInitial: false,
        participants: participants,
        numberOfParticipants: Random().nextInt(10000)));
  }

  Future<void> sendMessage(String msg) async {
    chatUseCases.sendMessage(msg: msg);
  }

  Future<void> setCurrentParticipant(Participant participant) async {
    chatUseCases.setCurrentParticipant(participant);
  }

  Future<void> chatMessageSeen(int index)
  async {
    chatUseCases.messageSeen(index: index);
  }
}