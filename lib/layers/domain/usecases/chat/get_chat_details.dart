import '../../repos/chat_repo.dart';

class GetChatDetails {
  GetChatDetails({required this.repo});

  final ChatRepo repo;

  call(int id) {
    repo.getChatDetails(id);
  }
}
