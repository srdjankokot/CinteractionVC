import 'package:cinteraction_vc/layers/domain/usecases/chat/get_messages.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_participants.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/message_seen.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/send_message.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_current_participant.dart';

import '../../repos/chat_repo.dart';
import 'chat_initialize.dart';

class ChatUseCases{
  final ChatRepo repo;
  ChatUseCases({required this.repo}) : 
        chatInitialize = ChatInitialize(repo: repo),
        sendMessage = SendMessage(repo: repo),
        getParticipantsStream = GetParticipantsStream(repo: repo),
        getMessageStream = GetMessagesStream(repo: repo),
        setCurrentParticipant = SetCurrentParticipant(repo: repo),
        messageSeen = MessageSeen(repo: repo)
  ;

  ChatInitialize chatInitialize;
  SendMessage sendMessage;
  GetParticipantsStream getParticipantsStream;
  GetMessagesStream getMessageStream;
  SetCurrentParticipant setCurrentParticipant;
  MessageSeen messageSeen;
}