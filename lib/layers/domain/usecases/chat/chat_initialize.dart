
import '../../repos/chat_repo.dart';

class ChatInitialize {
  ChatInitialize({required  this.repo});

  final ChatRepo repo;

  call({required int roomId, required bool isInCall}){
    repo.initialize(isInCall: isInCall, roomId: roomId);
  }
}