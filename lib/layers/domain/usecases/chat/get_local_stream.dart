import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';

import '../../../../core/io/network/models/participant.dart';
import '../../entities/chat_message.dart';

class GetLocalStream
{
  GetLocalStream({required  this.repo});

  final ChatRepo repo;
  Stream<StreamRenderer> call()
  {
    return repo.getLocalStream();
  }
}