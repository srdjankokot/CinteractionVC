import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../../data/dto/chat/chat_dto.dart';
import '../../../data/dto/chat/last_message_dto.dart';
import '../../../data/dto/user_dto.dart';
import '../../../domain/entities/chat_message.dart';

enum ListType {
  Chats,
  Users,
}

class ChatState extends Equatable {
  final bool isLoading;
  final bool isInitial;
  final List<Participant>? participants;
  final UserDto? currentParticipant;
  final ChatDto? currentChat;

  final List<UserDto>? users;
  final List<ChatMessage>? messages;
  final List<ChatDto>? chats;
  final ChatDetailsDto? chatDetails;
  final LastMessageDto? lastMessage;

  final int? stateIndex;
  final int unreadMessages;
  final bool? incomingCall;
  final bool? calling;
  final String? caller;
  final bool audioMuted;
  final bool videoMuted;
  final ListType listType;
  final StreamRenderer? localStream;
  final StreamRenderer? remoteStream;

  const ChatState({
    required this.isLoading,
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
    this.currentChat,
    this.users,
    this.chats,
    this.lastMessage,
    this.chatDetails,
    required this.audioMuted,
    required this.videoMuted,
    required this.listType,
  });

  const ChatState.initial({
    bool isLoading = true,
    bool isInitial = true,
    int unreadMessages = 0,
    bool audioMuted = false,
    bool videoMuted = false,
    ListType listType = ListType.Chats,
    ChatDetailsDto? chatDetails,
  }) : this(
          isLoading: isLoading,
          isInitial: isInitial,
          unreadMessages: unreadMessages,
          audioMuted: audioMuted,
          videoMuted: videoMuted,
          listType: listType,
          lastMessage: null,
          chatDetails: chatDetails,
        );

  @override
  List<Object?> get props => [
        isLoading,
        isInitial,
        participants,
        stateIndex,
        messages,
        chats,
        lastMessage,
        unreadMessages,
        incomingCall,
        caller,
        calling,
        localStream,
        remoteStream,
        currentParticipant,
        currentChat,
        users,
        audioMuted,
        videoMuted,
        listType,
        chatDetails,
      ];

  ChatState copyWith({
    bool? isLoading,
    bool? isInitial,
    List<Participant>? participants,
    List<ChatMessage>? messages,
    List<ChatDto>? chats,
    LastMessageDto? lastMessage,
    int? numberOfParticipants,
    int? unreadMessages,
    bool? incomingCall,
    String? caller,
    bool? calling,
    StreamRenderer? localStream,
    StreamRenderer? remoteStream,
    UserDto? currentParticipant,
    ChatDetailsDto? chatDetails,
    ChatDto? currentChat,
    List<UserDto>? users,
    bool? audioMuted,
    bool? videoMuted,
    ListType? listType,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isInitial: isInitial ?? this.isInitial,
      stateIndex: numberOfParticipants ?? this.stateIndex,
      messages: messages ?? this.messages,
      chats: chats ?? this.chats,
      lastMessage: lastMessage ?? this.lastMessage,
      participants: participants ?? this.participants,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      incomingCall: incomingCall ?? this.incomingCall,
      caller: caller ?? this.caller,
      calling: calling ?? this.calling,
      localStream: localStream ?? this.localStream,
      remoteStream: remoteStream ?? this.remoteStream,
      currentParticipant: currentParticipant ?? this.currentParticipant,
      currentChat: currentChat ?? this.currentChat,
      users: users ?? this.users,
      audioMuted: audioMuted ?? this.audioMuted,
      videoMuted: videoMuted ?? this.videoMuted,
      listType: listType ?? this.listType,
      chatDetails: chatDetails ?? this.chatDetails,
    );
  }

  ChatState callFinished() {
    return ChatState(
      isLoading: isLoading,
      isInitial: isInitial,
      stateIndex: stateIndex,
      users: users,
      messages: messages,
      chats: chats,
      lastMessage: lastMessage,
      participants: participants,
      unreadMessages: unreadMessages,
      incomingCall: false,
      caller: "",
      calling: false,
      localStream: null,
      remoteStream: null,
      currentParticipant: currentParticipant,
      currentChat: currentChat,
      audioMuted: audioMuted,
      videoMuted: videoMuted,
      listType: ListType.Chats,
      chatDetails: chatDetails,
    );
  }
}
