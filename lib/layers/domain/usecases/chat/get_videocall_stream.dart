import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../entities/chat_message.dart';

class GetVideoCallStream
{
  GetVideoCallStream({required  this.repo});

  final ChatRepo repo;
  Stream<String> call()
  {
    return repo.getVideoCallStream();
  }
}