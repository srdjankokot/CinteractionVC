import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'last_message_dto.dart';

class ChatDto {
  final int id;
  final String name;
  final String? userImage;
  final LastMessageDto? lastMessage;
  final List<ChatParticipantDto>? chatParticipants;
  bool isOnline;

  ChatDto({
    required this.id,
    required this.name,
    this.userImage,
    this.lastMessage,
    this.chatParticipants,
    this.isOnline = false,
  });

  factory ChatDto.fromJson(Map<String, dynamic> json) => ChatDto(
        id: json['chat_id'] as int,
        name: json['chat_name'] as String,
        userImage: json['user_image'],
        lastMessage: json['last_message'] != null
            ? LastMessageDto.fromJson(json['last_message'])
            : null,
        chatParticipants: json['chat_participants'] != null
            ? (json['chat_participants'] as List)
                .map((participant) => ChatParticipantDto.fromJson(participant))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        'chat_id': id,
        'chat_name': name,
        'user_image': userImage,
        'last_message': lastMessage?.toJson(),
        'chat_participants': chatParticipants?.map((p) => p.toJson()).toList(),
      };

  @override
  String toString() {
    return 'ChatDto(id: $id, name: $name, userImage: $userImage, lastMessage: $lastMessage, chatParticipants: $chatParticipants, isOnline: $isOnline)';
  }
}
