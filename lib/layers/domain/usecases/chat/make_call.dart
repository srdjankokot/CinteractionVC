import '../../repos/chat_repo.dart';

class MakeCall {
  MakeCall({required  this.repo});

  final ChatRepo repo;

  call({required String toUser}){
    repo.makeCall(toUser);
  }
}