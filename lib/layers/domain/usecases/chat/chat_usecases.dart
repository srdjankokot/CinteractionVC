import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chat_details.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chat_details_stream.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_chats_stream.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_messages.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_participants.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_users.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/message_seen.dart';

import 'package:cinteraction_vc/layers/domain/usecases/chat/send_file.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/send_message.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_current_chat.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_current_participant.dart';

import '../../repos/chat_repo.dart';
import 'chat_initialize.dart';
import 'choose_file.dart';

class ChatUseCases {
  final ChatRepo repo;

  ChatUseCases({required this.repo})
      : chatInitialize = ChatInitialize(repo: repo),
        sendMessage = SendMessage(repo: repo),
        getParticipantsStream = GetParticipantsStream(repo: repo),
        getMessageStream = GetMessagesStream(repo: repo),
        setCurrentParticipant = SetCurrentParticipant(repo: repo),
        messageSeen = MessageSeen(repo: repo),
        getUsersStream = GetUsersStream(repo: repo),
        sendFile = SendFile(repo: repo),
        chooseFile = ChooseFile(repo: repo),
        getChatsStream = GetChatsStream(repo: repo),
        setCurrentChat = SetCurrentChat(repo: repo),
        getChatDetails = GetChatDetails(repo: repo),
        getChatDetailsStream = GetChatDetailsStream(repo: repo);
  ChatInitialize chatInitialize;
  SendMessage sendMessage;
  GetParticipantsStream getParticipantsStream;
  GetMessagesStream getMessageStream;
  SetCurrentParticipant setCurrentParticipant;
  MessageSeen messageSeen;
  GetUsersStream getUsersStream;
  SendFile sendFile;
  ChooseFile chooseFile;
  GetChatsStream getChatsStream;
  SetCurrentChat setCurrentChat;
  GetChatDetails getChatDetails;
  GetChatDetailsStream getChatDetailsStream;
}
