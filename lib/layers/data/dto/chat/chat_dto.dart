import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'last_message_dto.dart';

class ChatDto {
  final int id;
  final String name;
  final String? userImage;
  final LastMessageDto? lastMessage;
  final List<ChatParticipantDto>? chatParticipants;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  ChatDto({
    required this.id,
    required this.name,
    this.userImage,
    this.lastMessage,
    this.chatParticipants,
    this.currentPage = 1,
    this.lastPage = 1,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory ChatDto.fromJson(Map<String, dynamic> json) => ChatDto(
        id: json['chat_id'] as int,
        name: json['chat_name'] as String,
        userImage: json['user_image'] as String?,
        lastMessage: (json['last_message'] != null &&
                json['last_message'] is Map<String, dynamic>)
            ? LastMessageDto.fromJson(json['last_message'])
            : null,
        chatParticipants: json['chat_participants'] != null
            ? (json['chat_participants'] as List)
                .map((participant) => ChatParticipantDto.fromJson(participant))
                .toList()
            : [],
        currentPage: json['meta']?['current_page'] as int? ?? 1,
        lastPage: json['meta']?['last_page'] as int? ?? 1,
        nextPageUrl: json['links']?['next'] as String?,
        prevPageUrl: json['links']?['prev'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'chat_id': id,
        'chat_name': name,
        'user_image': userImage,
        'last_message': lastMessage?.toJson(),
        'chat_participants': chatParticipants?.map((p) => p.toJson()).toList(),
        'meta': {
          'current_page': currentPage,
          'last_page': lastPage,
        },
        'links': {
          'next': nextPageUrl,
          'prev': prevPageUrl,
        },
      };

  @override
  String toString() {
    return 'ChatDto(id: $id, name: $name, userImage: $userImage, lastMessage: $lastMessage, chatParticipants: $chatParticipants, currentPage: $currentPage, lastPage: $lastPage, nextPageUrl: $nextPageUrl, prevPageUrl: $prevPageUrl)';
  }
}

class ChatPagination {
  final List<ChatDto> chats;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  ChatPagination({
    required this.chats,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory ChatPagination.fromJson(Map<String, dynamic> json) => ChatPagination(
        chats: (json['data'] as List)
            .map((chat) => ChatDto.fromJson(chat))
            .toList(),
        currentPage: json['meta']?['current_page'] as int? ?? 1,
        lastPage: json['meta']?['last_page'] as int? ?? 1,
        nextPageUrl: json['links']?['next'] as String?,
        prevPageUrl: json['links']?['prev'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'data': chats.map((chat) => chat.toJson()).toList(),
        'meta': {
          'current_page': currentPage,
          'last_page': lastPage,
        },
        'links': {
          'next': nextPageUrl,
          'prev': prevPageUrl,
        },
      };
}
