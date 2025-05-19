import '../../repos/chat_repo.dart';

class LoadUsers {
  LoadUsers({required this.repo});

  final ChatRepo repo;

  call(int page, int paginate) {
    repo.loadUsers(page, paginate);
  }
}
