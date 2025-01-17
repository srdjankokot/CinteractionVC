import '../../repos/chat_repo.dart';

class GetEmptyChat {
  GetEmptyChat({required this.repo});

  final ChatRepo repo;

  call() {
    repo.getEmptyChat();
  }
}
