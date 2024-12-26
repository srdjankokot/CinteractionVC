import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';
import 'package:cinteraction_vc/layers/domain/usecases/chat/set_current_chat.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:janus_client/janus_client.dart';
import 'package:logging/logging.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/app/injector.dart';
import '../../../core/io/network/models/participant.dart';
import '../../../core/util/util.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/user.dart';
import '../../domain/source/api.dart';
import '../dto/chat/last_message_dto.dart';
import '../source/local/local_storage.dart';

import '../../../core/util//conf.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

class ChatRepoImpl extends ChatRepo {
  ChatRepoImpl({required Api api}) : _api = api;
  User? user = getIt.get<LocalStorage>().loadLoggedUser();
  // User? user;

  final Api _api;
  int room = 1234;

  // final JanusClient _client;
  // int room = 111223;

  late String myId = user?.id ?? "";
  late String displayName = user?.name ?? 'User $myId';

  // late JanusClient client;
  late JanusSession _session;
  late JanusTextRoomPlugin textRoom;

  // late WebSocketJanusTransport ws;

  VideoRoomPluginStateManager videoState = VideoRoomPluginStateManager();

  final _participantsStream = StreamController<List<Participant>>.broadcast();

  final _usersStream = StreamController<List<UserDto>>.broadcast();

  final _chatStream = StreamController<List<ChatDto>>.broadcast();

  final _chatDetailsStream = StreamController<ChatDetailsDto>.broadcast();

  final _chatMessagesStream = StreamController<List<MessageDto>>.broadcast();

  final _messagesStream = StreamController<List<ChatMessage>>.broadcast();

  List<Participant> subscribers = [];
  List<UserDto> users = [];

  late ChatDetailsDto chatDetailsDto;

  UserDto? currentParticipant;
  List<ChatMessage> messages = [];

  ChatDto? currentChat;

  @override
  Future<void> initialize() async {
    _session = await getIt.getAsync<JanusSession>();
    await _attachPlugin();
    _loadUsers();
    _loadChats();
    _setup();
  }

  @override
  Stream<List<Participant>> getParticipantsStream() {
    return _participantsStream.stream;
  }

  @override
  Stream<List<UserDto>> getUsersStream() {
    return _usersStream.stream;
  }

  @override
  Stream<List<ChatDto>> getChatsStream() {
    return _chatStream.stream;
  }

  @override
  Stream<ChatDetailsDto> getChatDetailsStream() {
    return _chatDetailsStream.stream;
  }

  @override
  Stream<List<MessageDto>> sendMessageToChat() {
    return _chatMessagesStream.stream;
  }

  @override
  Stream<List<ChatMessage>> getMessageStream() {
    return _messagesStream.stream;
  }

  _editRoom() async {
    var exist = await textRoom.editRoom();
  }

  _checkRoom(int id) async {
    var exist = await textRoom.exists(id);
    print(exist);
    // JanusEvent event = JanusEvent.fromJson(exist);

    // print('room is exist: ${event.plugindata}');
    // if (event.plugindata?.data['exists'] == true) {
    if (exist!) {
      print('try to join publisher');
    } else {
      print('need to create the room');
      await _createRoom(id);
    }
  }

  _createRoom(int roomId) async {
    // Map<String, dynamic>? extras ={
    //   'publishers': maxPublishersDefault
    // };
    // var created = await textRoom.createRoom(roomId: room.toString(), adminKey: "supersecret", history: 10, isPrivate: false, description: "TestRoom", permanent: false, pin: "pin", secret: "secret", post: "https://7a2f-188-2-51-157.ngrok-free.app/api/message");
    var created =
        await textRoom.createRoom(roomId: roomId.toString(), permanent: true);
    // JanusEvent event = JanusEvent.fromJson(created);
    // if (event.plugindata?.data['videoroom'] == 'created') {
    //   // await _joinPublisher();
    // } else {
    //   print('error creating room');
    // }
  }

  _attachPlugin() async {
    print('eeeeeeeeeeeee');
    textRoom = await _session.attach<JanusTextRoomPlugin>();
    print('aaa $textRoom');
  }

  _leave() async {
    try {
      await textRoom.leaveRoom(room);
      textRoom.dispose();
      _session.dispose();
    } catch (e) {
      print('no connection skipping');
    }
  }

  _setup() async {
    await textRoom.setup();
    print(
      'textRoom $textRoom',
    );
    textRoom.onData?.listen((event) async {
      if (RTCDataChannelState.RTCDataChannelOpen == event) {
        await textRoom.joinRoom(
          room,
          user!.id,
          display: displayName,
          pin: "",
        );
      }
    });
    _setListener();
  }

  bool _haveUnread(Participant participant) {
    for (var message in participant.messages) {
      if (message.seen == false) {
        return true;
      }
    }

    return false;
  }

  _matchParticipantWithUser() {
    for (var element in users) {
      element.online = false;
    }
    for (var subscriber in subscribers) {
      UserDto fallbackUser = UserDto(
          id: "0",
          name: "name",
          email: "email",
          imageUrl: "imageUrl",
          createdAt: null);
      users
          .firstWhere(
            (item) => item.id == subscriber.id, // Condition that won't be met
            orElse: () => fallbackUser, // Return null if no element matches
          )
          .online = true;
    }
    _usersStream.add(users);
  }

  _setListener() {
    textRoom.data?.listen((event) {
      print('recieved message from data channel $event');
      dynamic data = parse(event.text);
      if (data != null) {
        if (data['textroom'] == 'message') {
          var initChat = chatDetailsDto.chatParticipants
              .firstWhere((item) => 'hash_${item.id}' == data['from']);
          var senderId = int.parse(data['from'].replaceAll('hash_', ''));
          if (initChat != null) {
            chatDetailsDto.messages.add(MessageDto(
                chatId: chatDetailsDto.chatId,
                senderId: senderId,
                createdAt: data['date'],
                message: data['text'],
                updatedAt: data['date']));

            _chatDetailsStream.add(chatDetailsDto);
          }

          var participant = subscribers
              .firstWhere((item) => item.id.toString() == data['from']);

          participant.haveUnreadMessages = _haveUnread(participant);
          // participant.messages.add(data['text']);
          participant.messages.add(ChatMessage(
              message: data['text'],
              displayName: participant.display,
              time: DateTime.parse(data['date']),
              avatarUrl: data['avatarUrl'] ?? "",
              seen: false));

          print("Unreaded messages: ${participant.haveUnreadMessages}");

          // messages.add(data['text']);

          _messagesStream.add(getUserMessages()!);
          _participantsStream.add(subscribers);
          _matchParticipantWithUser();
          print(data);
        }
        if (data['textroom'] == 'leave') {
          print('from: ${data['username']} Left The Chat!');
          subscribers = subscribers
              .where((item) => item.id.toString() != data['username'])
              .toList();
          _participantsStream.add(subscribers);
          _matchParticipantWithUser();
        }
        if (data['textroom'] == 'join') {
          print('from: ${data['username']} Joined The Chat!');

          if (data['username'] == displayName) {
            return;
          }

          if (subscribers
              .where((element) => element.id.toString() == data['username'])
              .toList()
              .isEmpty) {
            print("there is no participant with this display name");
            var participant =
                Participant(display: data['display'], id: data['username']);

            subscribers.add(participant);
          }

          _participantsStream.add(subscribers);
          _matchParticipantWithUser();
          // if (currentParticipant == null) setCurrentParticipant(subscribers.first);
        }
        if (data['participants'] != null) {
          for (var element in (data['participants'] as List<dynamic>)) {
            // setState(() {
            //   userNameDisplayMap.putIfAbsent(element['username'], () => element['display']);
            // });

            // var participant = Participant.fromJson(element as Map<String, dynamic>);
            var participant = Participant(
                display: element['display'], id: element['username']);
            // if(!participant.publisher){
            subscribers.add(participant);
            // }
            _participantsStream.add(subscribers);
            _matchParticipantWithUser();
          }
        }
      }
    });
  }

  List<ChatMessage>? getUserMessages() {
    for (var sub in subscribers) {
      if (sub.display == currentParticipant?.name) {
        return sub.messages;
      }
    }

    return List.empty();
  }

  @override
  Future<void> sendMessage(String msg, int participiantId) async {
    var pars = await textRoom.listParticipants(room);
    print('PAROVI $pars');
    // currentParticipant.display
    await textRoom.sendMessage(room, msg, to: 'hash_$participiantId');
    // var send =  await _api.sentChatMessage(text: msg, to: currentParticipant?.display, from: displayName);

    // print(send);
    // getUserMessages()?.add(ChatMessage(
    //     message: msg,
    //     displayName: 'Me',
    //     time: DateTime.now(),
    //     avatarUrl: user!.imageUrl,
    //     seen: true));
    // _messagesStream.add(getUserMessages()!);
  }

  @override
  Future<void> setCurrentParticipant(UserDto user) async {
    currentParticipant = user;
    messages = getUserMessages()!;
    _messagesStream.add(messages);
    print("Changed current participant");
  }

  @override
  Future<void> messageSeen(int index) async {
    var participant = subscribers
        .firstWhere((item) => item.display == currentParticipant?.name);

    messages = participant.messages;
    messages[index].seen = true;
    participant.haveUnreadMessages = _haveUnread(participant);

    // _messagesStream.add(messages);
    _participantsStream.add(subscribers);
    _matchParticipantWithUser();
  }

  _loadUsers() async {
    var response = await _api.getCompanyUsers();
    users = response.response!.where((element) => element.id != myId).toList();
    _matchParticipantWithUser();
  }

  ////API FUNCTIONS/////////////////

  _loadChats() async {
    var response = await _api.getAllChats();
    if (response.error == null) {
      List<ChatDto> chats = response.response ?? [];
      print('ChatsResponse: $chats');
      _chatStream.add(chats);
    } else {
      print('Error: ${response.error}');
    }
  }

  @override
  Future<void> setCurrentChat(ChatDto chat) async {
    currentChat = chat;
    messages = getUserMessages()!;
    _messagesStream.add(messages);
  }

  @override
  Future<void> getChatDetails(int id) async {
    try {
      var response = await _api.getChatById(id: id);
      if (response.error == null && response.response != null) {
        _chatDetailsStream.add(response.response!);
        chatDetailsDto = response.response!;
        print('chatDTAFAFA $chatDetailsDto');
      } else {
        print("Error: ${response.error}");
      }
    } catch (e) {
      print("Error while fetching chat: $e");
    }
  }

  @override
  Future<void> sendMessageToChatWrapper(
      int chatId, String messageContent, int senderId, List<int> participantIds,
      {List<File>? uploadedFiles}) async {
    await _api.sendMessageToChat(
      name: 'Sample Name',
      chatId: chatId,
      senderId: senderId,
      message: messageContent,
      participantIds: participantIds,
    );
  }

  //////////////////////////////////////

  @override
  Future<void> chooseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      uploadImageToStorage(file.name, file.bytes);
    } else {
      // User canceled the picker
    }
  }

  uploadImageToStorage(String name, Uint8List? bytes) async {
    if (kIsWeb) {
      Reference _reference = FirebaseStorage.instance
          .ref()
          .child('files/${Path.basename("$name")}');
      await _reference.putData(bytes!).whenComplete(() async {
        await _reference.getDownloadURL().then((value) {
          // uploadedPhotoUrl = value;

          print(value);
          // sendMessage(value);
        });
      });
    } else {
//write a code for android or ios
    }
  }

  @override
  Future<void> sendFile(String name, Uint8List bytes) async {
    uploadImageToStorage(name, bytes);
  }
}
