import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../entities/chat_message.dart';

class GetMessagesStream
{
  GetMessagesStream({required  this.repo});

  final ChatRepo repo;
  Stream<List<ChatMessage>>  call()
  {
    return repo.getMessageStream();
  }
}