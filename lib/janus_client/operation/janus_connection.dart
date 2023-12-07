import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../ice_server.dart';

/// 将流加入之后的执行
typedef OnAddStreamCallback = void Function(JanusConnection connection, MediaStream stream);
typedef OnAddTrackCallback = void Function(JanusConnection connection, MediaStream stream, MediaStreamTrack track);
typedef OnDataChannel = void Function(RTCDataChannel channel);

/// ice发送之后的执行
typedef OnIceCandidateCallback = void Function(JanusConnection connection, RTCIceCandidate candidate);

const Map<String, dynamic> _config = {
  'mandatory': {},
  'optional': [
    {'DtlsSrtpKeyAgreement': true},
  ],
};

const Map<String, dynamic> constraints = {
  'mandatory': {
    'OfferToReceiveAudio': true,
    'OfferToReceiveVideo': true,
  },
  'optional': [],
};

const Map<String, dynamic> noVideoconstraints = {
  'mandatory': {
    'OfferToReceiveAudio': true,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

const Map<String, dynamic> _iceServers = {
  'iceServers': [
    {
      'url': 'turn:turn.al.mancangyun:3478',
      'username': 'root',
      'credential': 'mypasswd'
    },
  ]
};

/// webrtc steps
/// 1. Get local media
/// 2. Create a connection
/// 3. Media connection and data
/// 4. Exchange description createOffer createAnswer sdp

/// janus connection object
class JanusConnection {
  int handleId; // janus handle ID
  List<RTCIceServer> iceServers;
  String display = ""; // Nick name
  int feedId; // janus session_id
  bool
      remote; // Whether it is a remote peer-to-peer connection（Not our own side）
  bool
      videoPresent; // Whether the video is displayed（Display limited far-end video stream）
  bool audio; // audio status
  bool video; // video status
  bool data; // video status

  int privateChatUnreadCount = 0;
  RTCPeerConnection _connection; // current peer connection object
  RTCVideoRenderer remoteRenderer; // Remote media data renderer
  MediaStream remoteStream; // Remote media data renderer
  RTCDataChannel dataChannel; // Remote media data renderer
  OnAddStreamCallback onAddStream;
  OnAddTrackCallback onAddTrack; // Add stream
  OnDataChannel onDataChannel;
  OnIceCandidateCallback onIceCandidate; // ice

  JanusConnection({
    @required this.handleId,
    this.iceServers,
    this.display,
    this.feedId,
    this.audio = true,
    this.video = true,
    this.data = true,
    this.remote = true,
    this.videoPresent = false,
  }) {
    debugPrint('JanusConnection init===$display==$feedId==$handleId');
    remoteRenderer = RTCVideoRenderer();
    // this.remoteRenderer.mirror = true;
    // this.remoteRenderer.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitCover;
  }

  /// init connect，init Remote media data renderer
  Future<void> initConnection() async {
    await remoteRenderer.initialize();
    await createConnection();
  }

  void disConnect() {
    debugPrint('JanusConnection disConnect===$display==$feedId==$handleId');
    _connection.close();
    remoteStream?.dispose();
    remoteRenderer?.dispose();
  }

  /// Set local session description added to RTCPeerConnection
  Future<RTCSessionDescription> createOffer({Map<String, dynamic> constraints = constraints}) async {

    RTCSessionDescription sdp = await _connection.createOffer(constraints);
    // RTCSessionDescription  changed = sdp;
    // changed.sdp = sdp.sdp.replaceAll("96 97 102", "102 96 97");

    // sdp.toMap()


    _connection.setLocalDescription(sdp);
    return sdp;
  }

  /// Add remote session description to RTCPeerConnection
  RTCSessionDescription setRemoteDescription(Map<String, dynamic> jsep) {
    RTCSessionDescription sdp =
        RTCSessionDescription(jsep['sdp'], jsep['type']);
    _connection.setRemoteDescription(sdp);
    return sdp;
  }


  /// Add local stream to RTCPeerConnection
  void addLocalStream(MediaStream localStream) {
    debugPrint('addLocalStream=====>$_connection');
    _connection.addStream(localStream);
  }

  void addLocalTrack(MediaStream localStream) {
    debugPrint('addLocalTrack=====>$_connection');
    localStream.getTracks().forEach((element) {


      // let sendEncodings = [
      //   {rid: 'q', codec: {clockRate: 90000, mimeType: 'video/AV1'}, scaleResolutionDownBy: 4.0, scalabilityMode: 'L1T3'},
      //   {rid: 'h', codec: {clockRate: 90000, mimeType: 'video/VP8'}, scaleResolutionDownBy: 2.0, scalabilityMode: 'L1T3'},
      //   {rid: 'f', codec: {clockRate: 90000, mimeType: 'video/VP8'}, scalabilityMode: 'L1T3'}
      // ];

      // _connection.addTransceiver(
      // track: element,
      // kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
      // init: RTCRtpTransceiverInit(
      //     direction: TransceiverDirection.SendOnly,
      //     sendEncodings: [
      //   RTCRtpEncoding(
      //     active: true,
      //     rid: 'l',
      //     scalabilityMode: 'L1T2',
      //     maxBitrate: 128000,
      //     maxFramerate: 10,
      //     scaleResolutionDownBy: 2)
      // ]));

      _connection.addTrack(element, localStream);
    });
  }

  /// reply sdp
  Future<RTCSessionDescription> createAnswer(
      {Map<String, dynamic> constraints = constraints}) async {
    RTCSessionDescription sdp = await _connection.createAnswer(constraints);
    // pass setLocalDescription notifies the browser of the session description and sends it to the remote peer to initiate the call
    _connection.setLocalDescription(sdp);
    return sdp;
  }

  Future createConnection() async {
    Map<String, dynamic> configuration = _iceServers;
    if (null != iceServers && iceServers.isNotEmpty) {
      configuration = {
        'iceServers': iceServers.map((e) => e.toMap()).toList(),
      };
    }
    _connection = await createPeerConnection(configuration, _config);
    // ice Add post-processing
    _connection.onIceCandidate = (candidate) => onIceCandidate(this, candidate);
    // stream add post-processing
    _connection.onAddStream = (stream) => onAddStream(this, stream);
    // stream remove post-processing
    _connection.onRemoveStream = (stream) {
      debugPrint("onRemoveStream");
    };

    dataChannel =  await _connection.createDataChannel("data channel", RTCDataChannelInit());
    // dataChannel.onDataChannelState = (state) => {
    //   debugPrint("data channel: state $state")
    // };
    //
    // dataChannel.onMessage = (message) => {
    //   debugPrint("data channel: message ${message.text} ")
    // };

    // channel data transfer processing


    _connection.onDataChannel = (dataChannel) => onDataChannel(dataChannel);


    _connection.onTrack = (event) => {debugPrint("onTrack")};

    _connection.onConnectionState =
        (state) => {debugPrint("onConnectionState")};

    _connection.onRenegotiationNeeded =
        () => {debugPrint("onRenegotiationNeeded")};

    _connection.onAddTrack = (stream, track) => onAddTrack(this, stream, track);



    return _connection;
  }


  void mute(String kind, bool enabled) async{
    var transrecievers = (await _connection.getTransceivers())
        ?.where((element) => element.sender.track.kind == kind)
        ?.toList();
    if (transrecievers.isEmpty) {
    return;
    }

    await transrecievers.first.setDirection(enabled ? TransceiverDirection.SendOnly : TransceiverDirection.Inactive);

  }

  void sendMessage(String message) async
  {

    await dataChannel.send(RTCDataChannelMessage(message));
  }
}
