import 'last_message_dto.dart';

class ChatDto {
  final int id;
  final String name;
  final LastMessageDto? lastMessage;

  ChatDto({
    required this.id,
    required this.name,
    this.lastMessage,
  });

  factory ChatDto.fromJson(Map<String, dynamic> json) => ChatDto(
        id: json['chat_id'] as int,
        name: json['chat_name'] as String,
        lastMessage: json['last_message'] != null
            ? LastMessageDto.fromJson(json['last_message'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'chat_id': id,
        'chat_name': name,
        'last_message': lastMessage?.toJson(),
      };

  // Override toString() metodu za bolji ispis
  @override
  String toString() {
    return 'ChatDto(id: $id, name: $name, lastMessage: $lastMessage)';
  }
}
