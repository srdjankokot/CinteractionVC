import 'package:cinteraction_vc/core/io/network/models/participant.dart';

import '../../repos/chat_repo.dart';

class SetCurrentParticipant {
  SetCurrentParticipant({required  this.repo});

  final ChatRepo repo;

  call(Participant participant){
    repo.setCurrentParticipant(participant);
  }
}