
import '../../repos/chat_repo.dart';

class ChatInitialize {
  ChatInitialize({required  this.repo});

  final ChatRepo repo;

  call(){
    repo.initialize();
  }
}