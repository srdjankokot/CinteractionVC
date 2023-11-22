import 'janus_client/ice_server.dart';

// String url = 'ws://localhost:5543';
String url = 'wss://server.institutonline.ai:55624';
// String url = 'wss://stan.kamenko.rs:8188';
// String url = 'wss://vc.cinteraction.com:8088';
bool withCredentials = false;
String apiSecret = "";

String mixTurnServerUsername = "nswd";
String mixTurnServerCredential = "vcnswd321";

List<RTCIceServer> iceServers = <RTCIceServer>[
  RTCIceServer(url: "stun:vc.cinteraction.com:3478"),
  // RTCIceServer(url: "stun:stun.l.google.com:19302"),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:80?transport=udp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:3478?transport=udp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:3478?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:80?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  RTCIceServer(
      url: "turns:vc.cinteraction.com:443?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  RTCIceServer(
      url: "turns:vc.cinteraction.com:5349?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
];
