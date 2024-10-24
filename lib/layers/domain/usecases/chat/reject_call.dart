import '../../repos/chat_repo.dart';

class RejectCall {
  RejectCall({required  this.repo});

  final ChatRepo repo;

  call(){
    repo.rejectCall();
  }
}