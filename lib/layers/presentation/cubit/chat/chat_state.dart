import 'package:equatable/equatable.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../domain/entities/chat_message.dart';

class ChatState extends Equatable
{
  final bool isInitial;
  final List<Participant>? participants;
  final List<ChatMessage>? messages;
  final int? numberOfParticipants;
  final int unreadMessages;

  const ChatState({
    required this.isInitial,
    this.messages,
    this.participants,
    this.numberOfParticipants,
    required this.unreadMessages
  });

  const ChatState.initial({
    bool isInitial = true,
    int unreadMessages = 0
  }) : this(isInitial: isInitial, unreadMessages: unreadMessages);

  @override
  List<Object?> get props =>  [isInitial, participants, numberOfParticipants, messages, unreadMessages];


  ChatState copyWith({
    bool? isInitial,
    List<Participant>? participants,
    List<ChatMessage>? messages,
    int? numberOfParticipants,
    int? unreadMessages,
})
  {
    return ChatState(
        isInitial: isInitial ?? this.isInitial,
        numberOfParticipants: numberOfParticipants ?? this.numberOfParticipants,
        messages: messages ?? this.messages,
        participants : participants?? this.participants,
        unreadMessages: unreadMessages?? this.unreadMessages
    );
  }
}