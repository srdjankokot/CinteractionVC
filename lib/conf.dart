import 'janus_client/ice_server.dart';

String url = 'wss://server.institutonline.ai:55624';
bool withCredentials = false;
String apiSecret = "";


String mixTurnServerUsername = "nswd";
String mixTurnServerCredential = "vcnswd321";

List<RTCIceServer> iceServers = <RTCIceServer>[
  RTCIceServer(
      url: "stun:vc.cinteraction.com:3478"
  ),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:80?transport=udp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:3478?transport=udp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:80?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:3478?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),
  RTCIceServer(
      url: "turns:vc.cinteraction.com:443?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),
  RTCIceServer(
      url: "turns:vc.cinteraction.com:5349?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential
  ),
];