import '../../repos/chat_repo.dart';

class SendMessage {
  SendMessage({required this.repo});

  final ChatRepo repo;

  call({
    required String msg,
    required int participiantId,
  }) {
    repo.sendMessage(msg, participiantId);
  }
}
