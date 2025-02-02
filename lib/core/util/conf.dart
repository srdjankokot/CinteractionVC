
import 'package:janus_client/janus_client.dart';

String url = 'wss://vc.cinteraction.com:8088';
bool withCredentials = false;
String apiSecret = "";

String mixTurnServerUsername = "nswd";
String mixTurnServerCredential = "vcnswd321";

int maxPublishersDefault = 9;

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

