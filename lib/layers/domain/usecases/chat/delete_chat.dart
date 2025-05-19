import '../../repos/chat_repo.dart';

class DeleteChat {
  DeleteChat({required this.repo});

  final ChatRepo repo;

  call(int id) {
    repo.deleteChat(id);
  }
}
