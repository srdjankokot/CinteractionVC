import '../../repos/chat_repo.dart';

class AnswerCall {
  AnswerCall({required  this.repo});

  final ChatRepo repo;

  call(){
    repo.answerCall();
  }
}