import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';

import '../../repos/chat_repo.dart';

class GetChatDetails {
  GetChatDetails({required this.repo});

  final ChatRepo repo;

  call(int id) {
    repo.getChatDetails(id);
  }
}
