import '../../repos/chat_repo.dart';

class LoadUsers {
  LoadUsers({required this.repo});

  final ChatRepo repo;

  call(int page, int paginate, String? search) {
    repo.loadUsers(page, paginate, search);
  }
}
