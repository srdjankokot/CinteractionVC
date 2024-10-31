import 'package:cinteraction_vc/core/util/util.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../data/dto/user_dto.dart';
import '../../../domain/entities/chat_message.dart';

class ChatState extends Equatable {
  final bool isInitial;
  final List<Participant>? participants;
  final UserDto? currentParticipant;

  final List<UserDto>? users;

  final List<ChatMessage>? messages;
  final int? numberOfParticipants;
  final int unreadMessages;
  final bool? incomingCall;
  final bool? calling;
  final StreamRenderer? localStream;
  final StreamRenderer? remoteStream;

  const ChatState({
    required this.isInitial,
    this.messages,
    this.participants,
    this.numberOfParticipants,
    required this.unreadMessages,
    this.incomingCall,
    this.calling,
    this.localStream,
    this.remoteStream,
    this.currentParticipant,
    this.users,
  });

  const ChatState.initial({bool isInitial = true, int unreadMessages = 0})
      : this(isInitial: isInitial, unreadMessages: unreadMessages);

  @override
  List<Object?> get props => [
        isInitial,
        participants,
        numberOfParticipants,
        messages,
        unreadMessages,
        incomingCall,
        calling,
        localStream,
        remoteStream,
        currentParticipant,
        users
      ];

  ChatState copyWith(
      {bool? isInitial,
      List<Participant>? participants,
      List<ChatMessage>? messages,
      int? numberOfParticipants,
      int? unreadMessages,
      bool? incomingCall,
      bool? calling,
      StreamRenderer? localStream,
      StreamRenderer? remoteStream,
      UserDto? currentParticipant,
      List<UserDto>? users}) {
    return ChatState(
      isInitial: isInitial ?? this.isInitial,
      numberOfParticipants: numberOfParticipants ?? this.numberOfParticipants,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      incomingCall: incomingCall ?? this.incomingCall,
      calling: calling ?? this.calling,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      currentParticipant: currentParticipant ?? this.currentParticipant,
      users: users ?? this.users,
    );
  }


    ChatState callFinished() {
      return ChatState(
        isInitial: isInitial,
        numberOfParticipants: numberOfParticipants,
        messages: messages,
        participants: participants,
        unreadMessages: unreadMessages,
        incomingCall: false,
        calling: false,
        localStream: null,
        remoteStream: null,
        currentParticipant: currentParticipant,
      );


  }
}
