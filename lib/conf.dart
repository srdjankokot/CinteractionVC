import 'janus_client/ice_server.dart';

String url = 'ws://192.168.0.67:5543';
bool withCredentials = false;
String apiSecret = "";


String mixTurnServerUsername = "nswd";
String mixTurnServerCredential = "vcnswd321";

// { urls: 'stun:stun.l.google.com:19302' },
// { urls: 'stun:stun1.l.google.com:19302' },
// { urls: 'stun:stun2.l.google.com:19302' },
// { urls: 'stun:stun3.l.google.com:19302' },
// { urls: 'stun:stun4.l.google.com:19302' }


List<RTCIceServer> iceServers = <RTCIceServer>[

  RTCIceServer(
      url: "stun:vc.cinteraction.com:3478"
  ),
  // RTCIceServer(
  //     url: "turn:vc.cinteraction.com:80?transport=udp",
  //     username: mixTurnServerUsername,
  //     credential: mixTurnServerCredential
  // ),


  RTCIceServer(
      url: "turn:vc.cinteraction.com:3478?transport=udp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:3478?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),

  RTCIceServer(
      url: "turn:vc.cinteraction.com:80?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),



  RTCIceServer(
      url: "turns:vc.cinteraction.com:443?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),
  // RTCIceServer(
  //     url: "turns:vc.cinteraction.com:5349?transport=tcp",
  //     username: mixTurnServerUsername,
  //     credential: mixTurnServerCredential
  // ),
];