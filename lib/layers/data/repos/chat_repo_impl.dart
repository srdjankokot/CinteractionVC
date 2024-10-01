import 'dart:async';
import 'dart:math';

import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';
import 'package:http/http.dart';
import 'package:janus_client/janus_client.dart';
import 'package:logging/logging.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/app/injector.dart';
import '../../../core/io/network/models/participant.dart';
import '../../../core/util/conf.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/user.dart';
import '../../domain/source/api.dart';
import '../source/local/local_storage.dart';

class ChatRepoImpl extends ChatRepo {
  ChatRepoImpl({required Api api}) : _api = api;
  User? user = getIt.get<LocalStorage>().loadLoggedUser();
  // User? user;

  final Api _api;
  int room = 1234;
  // int room = 111223;

  late int myId = user?.id ?? Random().nextInt(999999);
  late String displayName = user?.name ?? 'User $myId';

  late JanusClient client;
  late JanusSession session;
  late JanusTextRoomPlugin textRoom;
  late WebSocketJanusTransport ws;

  final _participantsStream = StreamController<List<Participant>>.broadcast();

  final _messagesStream = StreamController<List<ChatMessage>>.broadcast();

  List<Participant> subscribers = [];

  Participant? currentParticipant;
  List<ChatMessage> messages = [];

  @override
  Future<void> initialize() async {
    print("initialize janus");
    ws = WebSocketJanusTransport(url: url);
    client = JanusClient(
        transport: ws!,
        withCredentials: true,
        apiSecret: apiSecret,
        isUnifiedPlan: true,
        iceServers: iceServers,
        loggerLevel: Level.FINE);

    session = await client.createSession();
    await _attachPlugin();
    _setup();
    // _checkRoom();
  }

  _editRoom() async
  {
    var exist = await textRoom.editRoom();
  }


  _checkRoom() async {

    var exist = await textRoom.exists(room);
    print(exist);
    // JanusEvent event = JanusEvent.fromJson(exist);

    // print('room is exist: ${event.plugindata}');
    // if (event.plugindata?.data['exists'] == true) {
    if(exist!){
      print('try to join publisher');
    } else {
      print('need to create the room');
      await _createRoom(room);
    }
  }

  _createRoom(int roomId) async {
    // Map<String, dynamic>? extras ={
    //   'publishers': maxPublishersDefault
    // };
    // var created = await textRoom.createRoom(roomId: room.toString(), adminKey: "supersecret", history: 10, isPrivate: false, description: "TestRoom", permanent: false, pin: "pin", secret: "secret", post: "https://7a2f-188-2-51-157.ngrok-free.app/api/message");
    var created = await textRoom.createRoom(roomId: room, post: "https://f0f4-188-2-51-157.ngrok-free.app/api/message", permanent: true);
    print(created);
    // JanusEvent event = JanusEvent.fromJson(created);
    // if (event.plugindata?.data['videoroom'] == 'created') {
    //   // await _joinPublisher();
    // } else {
    //   print('error creating room');
    // }
  }

  _attachPlugin() async {
    textRoom = await session.attach<JanusTextRoomPlugin>();
  }

  _leave() async {
    try {
      await textRoom.leaveRoom(room);
      textRoom.dispose();
      session.dispose();
    } catch (e) {
      print('no connection skipping');
    }
  }

  _setup() async {
    await textRoom.setup();
    textRoom.onData?.listen((event) async {
      if (RTCDataChannelState.RTCDataChannelOpen == event) {
        await textRoom.joinRoom(room, displayName, display: displayName, pin: "",);
      }
    });

    _setListener();
  }

  bool _haveUnread(Participant participant)
  {
    for(var message in participant.messages)
      {
       if(message.seen == false)
         {
           return true;
         }
      }


    return false;
  }

  _setListener() {
    textRoom.data?.listen((event) {
      print('recieved message from data channel $event');
      dynamic data = parse(event.text);
      print(data);
      if (data != null) {
        if (data['textroom'] == 'message') {
          //
          // for(Participant prt in subscribers)
          //   {
          //     print(prt.display);
          //   }

          var participant = subscribers.firstWhere(
              (item) => item.display == data['from']); // or any default value);


          participant.haveUnreadMessages = _haveUnread(participant);
          // participant.messages.add(data['text']);
          participant.messages.add(ChatMessage(
              message: data['text'],
              displayName: data['from'],
              time: DateTime.parse(data['date']),
              avatarUrl: data['avatarUrl'] ?? "",
              seen: false));

          print("Unreaded messages: ${participant.haveUnreadMessages}");

          // messages.add(data['text']);
          _messagesStream.add(currentParticipant!.messages);
          _participantsStream.add(subscribers);
          print(data);
        }
        if (data['textroom'] == 'leave') {
          print('from: ${data['username']} Left The Chat!');
          subscribers = subscribers
              .where((item) => item.display != data['username'])
              .toList();
          _participantsStream.add(subscribers);
        }
        if (data['textroom'] == 'join') {
          print('from: ${data['username']} Joined The Chat!');

          if (data['username'] == displayName) {
            return;
          }

          var participant = Participant(
              display: data['username'], id: Random().nextInt(999999));

          subscribers.add(participant);
          _participantsStream.add(subscribers);
          if (currentParticipant == null) setCurrentParticipant(subscribers.first);
        }
        if (data['participants'] != null) {
          for (var element in (data['participants'] as List<dynamic>)) {
            // setState(() {
            //   userNameDisplayMap.putIfAbsent(element['username'], () => element['display']);
            // });

            // var participant = Participant.fromJson(element as Map<String, dynamic>);
            var participant = Participant(
                display: element['username'], id: Random().nextInt(999999));
            // if(!participant.publisher){
            subscribers.add(participant);
            // }
            _participantsStream.add(subscribers);
          }
        }
      }
    });
  }

  @override
  Stream<List<Participant>> getParticipantsStream() {
    return _participantsStream.stream;
  }

  @override
  Future<void> sendMessage(String msg) async {
    // currentParticipant.display
    await textRoom.sendMessage(room, msg, to: currentParticipant?.display);
   // var send =  await _api.sentChatMessage(text: msg, to: currentParticipant?.display, from: displayName);

   // print(send);
    currentParticipant?.messages.add(ChatMessage(
        message: msg,
        displayName: 'Me',
        time: DateTime.now(),
        avatarUrl: user!.imageUrl,
        seen: true));

    _messagesStream.add(currentParticipant!.messages);



  }

  @override
  Future<void> setCurrentParticipant(Participant participant) async {
    currentParticipant = participant;
    messages = currentParticipant!.messages;
    _messagesStream.add(messages);
    print("Changed current participant");
  }

  @override
  Stream<List<ChatMessage>> getMessageStream() {
    return _messagesStream.stream;
  }

  @override
  Future<void> messageSeen(int index) async {
    var participant = subscribers.firstWhere((item) => item.display == currentParticipant?.display);

    messages = participant.messages;
    messages[index].seen = true;
    participant.haveUnreadMessages = _haveUnread(participant);

    // _messagesStream.add(messages);
    _participantsStream.add(subscribers);
  }
}
