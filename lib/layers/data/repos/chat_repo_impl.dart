import 'dart:async';
import 'dart:math';

import 'package:cinteraction_vc/layers/data/dto/user_dto.dart';
import 'package:cinteraction_vc/layers/domain/repos/chat_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:janus_client/janus_client.dart';
import 'package:logging/logging.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/app/injector.dart';
import '../../../core/io/network/models/participant.dart';
import '../../../core/util/conf.dart';
import '../../../core/util/util.dart';
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


  late JanusVideoCallPlugin videoCallPlugin;
  late StreamRenderer _localVideoRenderer;
  late StreamRenderer _remoteVideoRenderer;

  late RTCSessionDescription? remoteJsep;

  VideoRoomPluginStateManager videoState = VideoRoomPluginStateManager();


  final _participantsStream = StreamController<List<Participant>>.broadcast();

  final _usersStream = StreamController<List<UserDto>>.broadcast();

  final _messagesStream = StreamController<List<ChatMessage>>.broadcast();

  final _videoCallStream = StreamController<String>.broadcast();

  List<Participant> subscribers = [];

  Participant? currentParticipant;
  List<ChatMessage> messages = [];


  final _localStream = StreamController<StreamRenderer>.broadcast();
  final _remoteStream = StreamController<StreamRenderer>.broadcast();

  @override
  Future<void> initialize() async {
    print("initialize janus");

    _loadUsers();

    ws = WebSocketJanusTransport(url: url);
    client = JanusClient(
        transport: ws!,
        withCredentials: true,
        apiSecret: apiSecret,
        isUnifiedPlan: true,
        iceServers: iceServers,
        loggerLevel: Level.FINE);

    // session = await client.createSession();
    // await _attachPlugin();
    // _setup();

    await _configureConnection();
    // _registerUser();
    // _checkRoom();
  }


  @override
  Stream<StreamRenderer> getLocalStream() {
    return _localStream.stream;
  }

  @override
  Stream<StreamRenderer> getRemoteStream() {
    return _remoteStream.stream;
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
  Stream<List<ChatMessage>> getMessageStream() {
    return _messagesStream.stream;
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
    var created = await textRoom.createRoom(roomId: room.toString(), permanent: true);
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


          if(subscribers.where((element) => element.display == data['username']).toList().isEmpty){
            print("there is no participant with this display name");
            var participant = Participant(display: data['username'], id: Random().nextInt(999999));

            subscribers.add(participant);
          }


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
  Future<void> messageSeen(int index) async {
    var participant = subscribers.firstWhere((item) => item.display == currentParticipant?.display);

    messages = participant.messages;
    messages[index].seen = true;
    participant.haveUnreadMessages = _haveUnread(participant);

    // _messagesStream.add(messages);
    _participantsStream.add(subscribers);
  }

  _loadUsers() async
  {
    var response = await _api.getCompanyUsers();
    var users = response.response;
    _usersStream.add(users!);
  }

/**
 *
 * VIDEO CALL PART
 *
 */

  _configureConnection() async{
    session = await client.createSession();

    await _attachPlugin();
    _setup();

    videoCallPlugin = await session.attach<JanusVideoCallPlugin>();

    videoCallPlugin.data?.listen((event) async {
      print(event.text);//i think this is for chat in call
      // setState(() {
      //   messages.add(event.text);
      // });
    });
    videoCallPlugin.webRTCHandle?.peerConnection?.onConnectionState = (connectionState) async {
      print("PEER CONNECTION STATE: $connectionState");
      if (connectionState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('connection established');
      }
    };



    videoCallPlugin.remoteTrack?.listen((event) async {
      if (event.track != null && event.flowing == true) {
        _remoteVideoRenderer = StreamRenderer('remote', 'remote');
        await _remoteVideoRenderer.init();
        _remoteVideoRenderer.mediaStream?.addTrack(event.track!);
        // remoteVideoStream?.addTrack(event.track!);
        _remoteVideoRenderer.videoRenderer.srcObject = _remoteVideoRenderer.mediaStream;
        // this is done only for web since web api are muted by default for local tagged mediaStream
        if (kIsWeb) {
          _remoteVideoRenderer.isVideoMuted = false;
          _remoteVideoRenderer.isAudioMuted = false;
        }

        _remoteStream.add(_remoteVideoRenderer);
      }
    });


    videoCallPlugin.typedMessages?.listen((even) async {
      Object data = even.event.plugindata?.data;
      if (data is VideoCallRegisteredEvent) {
        print('VideoCallRegisteredEvent');
        // Navigator.of(context).pop(registerDialog);
        // print(data.result?.username);
        // nameController.clear();
        // await makeCallDialog();
      }
      if (data is VideoCallIncomingCallEvent) {
        print("VideoCallIncomingCallEvent");
        // incomingDialog = await showIncomingCallDialog(data.result!.username!, even.jsep);
        remoteJsep = even.jsep;
        _videoCallStream.add("IncomingCall");
      }
      if (data is VideoCallAcceptedEvent) {
        // setState(() {
        //   ringing = false;
        // });
        print("video call is accepted");
        await videoCallPlugin.handleRemoteJsep(even.jsep);
      }
      if (data is VideoCallCallingEvent) {
        print("VideoCallCallingEvent start ringing");
        _videoCallStream.add("Calling");
        // Navigator.of(context).pop(callDialog);
        // setState(() {
        //   ringing = true;
        // });
      }
      if (data is VideoCallUpdateEvent) {
        if (even.jsep != null) {
          if (even.jsep?.type == "answer") {
            videoCallPlugin.handleRemoteJsep(even.jsep);
          } else {
            var answer = await videoCallPlugin.createAnswer();
            await videoCallPlugin.set(jsep: answer);
          }
        }
      }
      if (data is VideoCallHangupEvent) {
        await destroy();
      }
    }, onError: (error) async {
      if (error is JanusError) {

        print(error);
        // var dialog;
        // dialog = await showDialog(
        //     context: context,
        //     builder: (context) {
        //       return AlertDialog(
        //         actions: [
        //           TextButton(
        //               onPressed: () async {
        //                 Navigator.of(context).pop(dialog);
        //                 nameController.clear();
        //               },
        //               child: Text('Okay'))
        //         ],
        //         title: Text('Whoops!'),
        //         content: Text(error.error),
        //       );
        //     });
      }
    });

    _registerUser();
    // videoCallPlugin.getList();
  }

  Future<void> _registerUser() async {
    await videoCallPlugin.register(displayName);
  }

  destroy() async {
    rejectCall();
  }

  @override
  Future<void> makeCall(String user) async{
    await _configureLocalVideoRenderer();
    await videoCallPlugin.call(user);
  }

  @override
  Stream<String> getVideoCallStream() {
    return _videoCallStream.stream;
  }


  @override
  Future<void> answerCall() async{
    await _configureLocalVideoRenderer();
    await videoCallPlugin.handleRemoteJsep(remoteJsep);
    var answer = await videoCallPlugin.createAnswer();
    await videoCallPlugin.acceptCall(answer: answer);
  }

  @override
  Future<void> rejectCall() async {
    await videoCallPlugin.hangup();
    // await videoCallPlugin.send(data: {"request": "hangup"});
    _videoCallStream.add("Rejected");
    remoteJsep = null;

     session.dispose();
    // _cleanupWebRTC();

    await _configureConnection();
  }

  _configureLocalVideoRenderer() async {
    _localVideoRenderer = StreamRenderer('local', 'local');
    await _localVideoRenderer.init();
    _localVideoRenderer.mediaStream = await videoCallPlugin.initializeMediaDevices(mediaConstraints: {
      'video': {'width': 640, 'height': 360},
      'audio': true
    });

    _localVideoRenderer.videoRenderer.srcObject = _localVideoRenderer.mediaStream;
    _localVideoRenderer.publisherName = displayName;
    _localVideoRenderer.publisherId = myId.toString();

    _localStream.add(_localVideoRenderer);
  }

  Future<void> cleanUpWebRTCStuff() async {
    _localVideoRenderer.videoRenderer.srcObject = null;
    _remoteVideoRenderer.videoRenderer.srcObject = null;
    _localVideoRenderer.dispose();
    _remoteVideoRenderer.dispose();
  }

}
