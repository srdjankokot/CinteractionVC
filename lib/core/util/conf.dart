import '../janus/janus_client.dart';

String baseUrl = 'https://vc.cinteraction.com';

//janus conf
String url = "wss://vc.cinteraction.com:8088";
bool withCredentials = false;
String apiSecret = "";
int maxPublishersDefault = 30;

//stun/turn server cong
String mixTurnServerUsername = 'nswd';
String mixTurnServerCredential = 'vcnswd321';

List<RTCIceServer> iceServers = <RTCIceServer>[

  RTCIceServer(urls: "stun:vc.cinteraction.com:3478", username: "", credential: ""),
  RTCIceServer(
      urls: "turn:vc.cinteraction.com:3478?transport=udp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  RTCIceServer(
      urls: "turn:vc.cinteraction.com:3478?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),

];