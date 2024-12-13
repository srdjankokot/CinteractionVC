class LastMessageDto {
  final int id;
  final int chatId;
  final int senderId;
  final String? message;
  final String? filePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  LastMessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.message,
    this.filePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LastMessageDto.fromJson(Map<String, dynamic> json) => LastMessageDto(
        id: json['id'] as int,
        chatId: json['chatId'] as int,
        senderId: json['sender_id'] as int,
        message: json['message'] as String?,
        filePath: json['file_path'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'sender_id': senderId,
        'message': message,
        'file_path': filePath,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
