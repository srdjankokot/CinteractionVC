import 'package:cinteraction_vc/layers/domain/usecases/chat/answer_call.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_messages.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_participants.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/get_users.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/message_seen.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/reject_call.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/send_message.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_current_participant.dart';

import '../../repos/chat_repo.dart';
import 'chat_initialize.dart';
import 'get_local_stream.dart';
import 'get_remote_stream.dart';
import 'get_videocall_stream.dart';
import 'make_call.dart';

class ChatUseCases{
  final ChatRepo repo;
  ChatUseCases({required this.repo}) : 
        chatInitialize = ChatInitialize(repo: repo),
        sendMessage = SendMessage(repo: repo),
        getParticipantsStream = GetParticipantsStream(repo: repo),
        getMessageStream = GetMessagesStream(repo: repo),
        setCurrentParticipant = SetCurrentParticipant(repo: repo),
        messageSeen = MessageSeen(repo: repo),
        makeCall = MakeCall(repo: repo),
        videoCallStream = GetVideoCallStream(repo: repo),
        rejectCall = RejectCall(repo: repo),
        getLocalStream = GetLocalStream(repo: repo),
        getRemoteStream = GetRemoteStream(repo: repo),
        answerCall = AnswerCall(repo: repo),
        getUsersStream = GetUsersStream(repo: repo)
  ;

  ChatInitialize chatInitialize;
  SendMessage sendMessage;
  GetParticipantsStream getParticipantsStream;
  GetMessagesStream getMessageStream;
  SetCurrentParticipant setCurrentParticipant;
  MessageSeen messageSeen;
  MakeCall makeCall;
  GetVideoCallStream videoCallStream;
  RejectCall rejectCall;
  GetLocalStream getLocalStream;
  GetRemoteStream getRemoteStream;
  AnswerCall answerCall;
  GetUsersStream getUsersStream;
}