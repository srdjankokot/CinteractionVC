
import '../../repos/conference_repo.dart';

class ConferenceSendMessage{

  ConferenceSendMessage({required  this.repo});

  final ConferenceRepo repo;

  call(String msg) {
    repo.sendMessage(msg);
  }
}
