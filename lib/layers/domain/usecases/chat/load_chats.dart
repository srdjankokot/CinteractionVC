import '../../repos/chat_repo.dart';

class LoadChats {
  LoadChats({required this.repo});

  final ChatRepo repo;

  call(int page, int paginate) {
    repo.loadChats(page, paginate);
  }
}
