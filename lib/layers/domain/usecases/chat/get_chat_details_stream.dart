import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';

import '../../repos/chat_repo.dart';

class GetChatDetailsStream {
  GetChatDetailsStream({required this.repo});

  final ChatRepo repo;

  // Sada vraća Stream<ChatDetailsDto> umesto Stream<List<MessageDto>>
  Stream<ChatDetailsDto> call() {
    return repo.getChatDetailsStream();
  }
}
