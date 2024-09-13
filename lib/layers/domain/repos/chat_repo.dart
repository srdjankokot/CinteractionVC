import '../../../core/io/network/models/participant.dart';
import '../entities/chat_message.dart';

abstract class ChatRepo{
  const ChatRepo();


  Future<void> initialize();
  Future<void> sendMessage(String msg);
  Stream<List<Participant>> getParticipantsStream();
  Stream<List<ChatMessage>> getMessageStream();
  Future<void> setCurrentParticipant(Participant participant);
}