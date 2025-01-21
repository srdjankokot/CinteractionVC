class ChatParticipantDto {
  final int id;
  final String image;
  final String name;
  final String email;
  bool isOnline;

  ChatParticipantDto({
    required this.id,
    required this.image,
    required this.name,
    required this.email,
    this.isOnline = false,
  });

  factory ChatParticipantDto.fromJson(Map<String, dynamic> json) =>
      ChatParticipantDto(
        id: json['id'] as int,
        image: json['image'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'image': image,
        'name': name,
        'email': email,
      };

  @override
  String toString() {
    return 'ChatParticipantDto(id: $id, image: $image, name: $name, email: $email, isOnline: $isOnline)';
  }
}

class MessageDto {
  final int? id;
  final int chatId;
  final int senderId;
  final String? message;
  final List<String>? filePath;
  final String createdAt;
  final String updatedAt;

  MessageDto({
    this.id,
    required this.chatId,
    required this.senderId,
    this.message,
    this.filePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) => MessageDto(
        id: json['id'] as int? ?? 0,
        chatId: json['chat_id'] as int? ?? 0,
        senderId: json['sender_id'] as int? ?? 0,
        message: json['message'] as String?,
        filePath: List<String>.from(json['file_path'] ?? []),
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'chat_id': chatId,
        'sender_id': senderId,
        'message': message,
        'file_path': filePath,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  @override
  String toString() {
    return 'MessageDto(id: $id, chatId: $chatId, senderId: $senderId, message: $message, filePath: $filePath, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

class ChatDetailsDto {
  final int? chatId;
  final String? chatName;
  final ChatParticipantDto authUser;
  final List<ChatParticipantDto> chatParticipants;
  final List<MessageDto> messages;
  final bool isOnline;

  ChatDetailsDto(
      {required this.chatId,
      required this.chatName,
      required this.authUser,
      required this.chatParticipants,
      required this.messages,
      this.isOnline = false});

  factory ChatDetailsDto.fromJson(Map<String, dynamic> json) => ChatDetailsDto(
        chatId: json['chat_id'] as int?,
        chatName: json['chat_name'] as String?,
        authUser: ChatParticipantDto.fromJson(json['auth_user']),
        chatParticipants: (json['chat_participants'] as List)
            .map((participant) => ChatParticipantDto.fromJson(participant))
            .toList(),
        messages: (json['messages'] as List)
            .map((message) => MessageDto.fromJson(message))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'chat_id': chatId,
        'chat_name': chatName,
        'auth_user': authUser.toJson(),
        'chat_participants': chatParticipants.map((p) => p.toJson()).toList(),
        'messages': messages.map((message) => message.toJson()).toList(),
      };

  @override
  String toString() {
    return 'ChatDetailsDto(chatId: $chatId, chatName: $chatName, authUser: $authUser, chatParticipants: $chatParticipants, messages: $messages , isOnline: $isOnline)';
  }
}
