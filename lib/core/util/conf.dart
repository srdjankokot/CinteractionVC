
// String url = 'wss://vc.cinteraction.com:8088';
// bool withCredentials = false;
// String apiSecret = "";
//
import '../janus/janus_client.dart';

String url = "wss://vc.cinteraction.com:8088";
bool withCredentials = false;
String apiSecret = "";

String mixTurnServerUsername = 'nswd';
String mixTurnServerCredential = 'vcnswd321';
//
int maxPublishersDefault = 30;
//
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




// String mixTurnServerUsername = "nswd";
// String mixTurnServerCredential = "vcnswd321";
//
// //HUAWEI
// String url = "wss://huawei.nswebdevelopment.com:8189";
// bool withCredentials = false;
// String apiSecret = "";
//
// String mixTurnServerUsernameHuawei = 'test';
// String mixTurnServerCredentialHuawei = 'test123';
//
// int maxPublishersDefault = 30;
//
// List<RTCIceServer> iceServers = <RTCIceServer>[
//   RTCIceServer(
//       urls: 'stun:cinteraction.nswebdevelopment.com:3478',
//       username: "",
//       credential: ""),
//   RTCIceServer(
//       urls: 'turn:cinteraction.nswebdevelopment.com:3478?transport=udp',
//       username: mixTurnServerUsernameHuawei,
//       credential: mixTurnServerCredentialHuawei),
//   RTCIceServer(
//       urls: 'turn:cinteraction.nswebdevelopment.com:3478?transport=tcp',
//       username: mixTurnServerUsernameHuawei,
//       credential: mixTurnServerCredentialHuawei),
//
//   // RTCIceServer(
//   //     urls: 'stun:huawei.nswebdevelopment.com:3478',
//   //     username: "",
//   //     credential: ""),
//   // RTCIceServer(
//   //     urls: 'turn:huawei.nswebdevelopment.com:3478?transport=udp',
//   //     username: mixTurnServerUsernameHuawei,
//   //     credential: mixTurnServerCredentialHuawei),
//   // RTCIceServer(
//   //     urls: 'turn:huawei.nswebdevelopment.com:3478?transport=tcp',
//   //     username: mixTurnServerUsernameHuawei,
//   //     credential: mixTurnServerCredentialHuawei),
//
//
//
// ];
