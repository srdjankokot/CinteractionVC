import 'dart:io';

import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';

import '../../repos/chat_repo.dart';

class SendMessageToChatStream {
  SendMessageToChatStream({required this.repo});

  final ChatRepo repo;

  call({
    required int chatId,
    required String messageContent,
    required int senderId,
    required List<int> participantIds,
    List<File>? uploadedFiles,
  }) {
    return repo.sendMessageToChatWrapper(
      chatId,
      messageContent,
      senderId,
      participantIds,
      uploadedFiles: uploadedFiles,
    );
  }
}
