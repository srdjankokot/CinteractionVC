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
  final int? stateIndex;
  final int unreadMessages;
  final bool? incomingCall;
  final bool? calling;
  final String? caller;
  final bool audioMuted;
  final bool videoMuted;
  final StreamRenderer? localStream;
  final StreamRenderer? remoteStream;

  const ChatState({
    required this.isInitial,
    this.messages,
    this.participants,
    this.stateIndex,
    required this.unreadMessages,
    this.incomingCall,
    this.caller,
    this.calling,
    this.localStream,
    this.remoteStream,
    this.currentParticipant,
    this.users,
    required this.audioMuted,
    required this.videoMuted,
  });

  const ChatState.initial({
    bool isInitial = true,
    int unreadMessages = 0,
    bool audioMuted = false,
    bool videoMuted = false,
  }) : this(
            isInitial: isInitial,
            unreadMessages: unreadMessages,
            audioMuted: audioMuted,
            videoMuted: videoMuted);

  @override
  List<Object?> get props => [
        isInitial,
        participants,
        stateIndex,
        messages,
        unreadMessages,
        incomingCall,
        caller,
        calling,
        localStream,
        remoteStream,
        currentParticipant,
        users,
        audioMuted,
        videoMuted
      ];

  ChatState copyWith({
    bool? isInitial,
    List<Participant>? participants,
    List<ChatMessage>? messages,
    int? numberOfParticipants,
    int? unreadMessages,
    bool? incomingCall,
    String? caller,
    bool? calling,
    StreamRenderer? localStream,
    StreamRenderer? remoteStream,
    UserDto? currentParticipant,
    List<UserDto>? users,
    bool? audioMuted,
    bool? videoMuted,
  }) {
    return ChatState(
      isInitial: isInitial ?? this.isInitial,
      stateIndex: numberOfParticipants ?? this.stateIndex,
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      incomingCall: incomingCall ?? this.incomingCall,
      caller: caller ?? this.caller,
      calling: calling ?? this.calling,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      currentParticipant: currentParticipant ?? this.currentParticipant,
      users: users ?? this.users,
      audioMuted: audioMuted ?? this.audioMuted,
      videoMuted: videoMuted ?? this.videoMuted,
    );
  }

  ChatState callFinished() {
    return ChatState(
      isInitial: isInitial,
      stateIndex: stateIndex,
      users: users,
      messages: messages,
      participants: participants,
      unreadMessages: unreadMessages,
      incomingCall: false,
      caller: "",
      calling: false,
      localStream: null,
      remoteStream: null,
      currentParticipant: currentParticipant,
      audioMuted: audioMuted,
      videoMuted: videoMuted,
    );
  }
}
