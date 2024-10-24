import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:janus_client/janus_client.dart';
import 'package:logging/logging.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../core/app/injector.dart';
import '../../../core/util/conf.dart';
import '../../../core/util/util.dart';
import '../../domain/entities/user.dart';
import '../../domain/repos/video_call_repo.dart';
import '../../domain/source/api.dart';
import '../source/local/local_storage.dart';

class VideoCallRepoImpl extends VideoCallRepo {


  late JanusClient client;
  late WebSocketJanusTransport ws;
  late JanusSession session;

  late JanusVideoCallPlugin videoCallPlugin;


  User? user = getIt.get<LocalStorage>().loadLoggedUser();
  late int myId = user?.id ?? Random().nextInt(999999);
  late String displayName = user?.name ?? 'User $myId';


  // RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late StreamRenderer _localVideoRenderer;

  // RTCVideoRenderer _remoteVideoRenderer = RTCVideoRenderer();
  late StreamRenderer _remoteVideoRenderer;

  @override
  Future<void> initialize() async {

    displayName = user!.name;

    ws = WebSocketJanusTransport(url: url);
    client = JanusClient(
        transport: ws!,
        withCredentials: true,
        apiSecret: apiSecret,
        isUnifiedPlan: true,
        iceServers: iceServers,
        loggerLevel: Level.FINE);
    session = await client.createSession();

    _configureConnection();
  }


  _configureConnection() async{
    videoCallPlugin = await session.attach<JanusVideoCallPlugin>();

    videoCallPlugin.data?.listen((event) async {
      print(event.text);//i think this is for chat in call
      // setState(() {
      //   messages.add(event.text);
      // });
    });
    videoCallPlugin.webRTCHandle?.peerConnection?.onConnectionState = (connectionState) async {
      if (connectionState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        print('connection established');
      }
    };
    videoCallPlugin.remoteTrack?.listen((event) async {
      if (event.track != null && event.flowing == true) {
        await _remoteVideoRenderer.init();
        _remoteVideoRenderer.mediaStream?.addTrack(event.track!);
        // remoteVideoStream?.addTrack(event.track!);
        _remoteVideoRenderer.videoRenderer.srcObject = _remoteVideoRenderer.mediaStream;
        // this is done only for web since web api are muted by default for local tagged mediaStream
        if (kIsWeb) {
          _remoteVideoRenderer.isVideoMuted = false;
          _remoteVideoRenderer.isAudioMuted = false;
        }
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
  }

  Future<void> _registerUser() async {
      await videoCallPlugin.register(displayName);
  }

  destroy() async {
    await stopAllTracksAndDispose(videoCallPlugin.webRTCHandle?.localStream);
    await stopAllTracksAndDispose(_remoteVideoRenderer.mediaStream);
    videoCallPlugin.dispose();
    session.dispose();
    // Navigator.of(context).pop();
  }

  @override
  Future<void> makeCall(String user) async{
    await _configureLocalVideoRenderer();
    await videoCallPlugin.initDataChannel();
    var offer = await videoCallPlugin.createOffer(
      audioRecv: true,
      videoRecv: true,
    );
    await videoCallPlugin.call(user, offer: offer);
  }

  @override
  Stream<String> incomingCall() {
    // TODO: implement incomingCall
    throw UnimplementedError();
  }

  @override
  Future<void> answerCall(String caller, RTCSessionDescription? jsep) async{
    await _configureLocalVideoRenderer();
    await videoCallPlugin.handleRemoteJsep(jsep);
    var answer = await videoCallPlugin.createAnswer();
    await videoCallPlugin.acceptCall(answer: answer);
  }

  @override
  Future<void> rejectCall() async {
    await videoCallPlugin.hangup();
  }
  _configureLocalVideoRenderer() async {
    await _localVideoRenderer.init();
    _localVideoRenderer.mediaStream = await videoCallPlugin.initializeMediaDevices(mediaConstraints: {
      'video': {'width': 640, 'height': 360},
      'audio': true
    });

    _localVideoRenderer.videoRenderer.srcObject = _localVideoRenderer.mediaStream;
    _localVideoRenderer.publisherName = displayName;
    _localVideoRenderer.publisherId = myId.toString();
  }

  Future<void> cleanUpWebRTCStuff() async {
    _localVideoRenderer.videoRenderer.srcObject = null;
    _remoteVideoRenderer.videoRenderer.srcObject = null;
    _localVideoRenderer.dispose();
    _remoteVideoRenderer.dispose();
  }
}
