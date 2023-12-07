import 'janus_client/ice_server.dart';

// String url = 'ws://192.168.0.67:5543';
// String url = 'wss://server.institutonline.ai:55624';
// String url = 'wss://stan.kamenko.rs:8188';
String url = 'wss://vc.cinteraction.com:8088';
bool withCredentials = false;
String apiSecret = "";

String mixTurnServerUsername = "nswd";
String mixTurnServerCredential = "vcnswd321";

List<RTCIceServer> iceServers = <RTCIceServer>[
  //
  // RTCIceServer(url: "stun:stan.kamenko.rs:3478"),
  RTCIceServer(url: "stun:vc.cinteraction.com:3478"),
  // RTCIceServer(url: "stun:stun.l.google.com:19302"),
  // RTCIceServer(url: "stun:server.institutonline.ai:55611"),
  // RTCIceServer(url: "stun:global.stun.twilio.com:3478"),
  // RTCIceServer(
  //     url: "turn:vc.cinteraction.com:80?transport=udp",
  //     username: mixTurnServerUsername,
  //     credential: mixTurnServerCredential),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:3478?transport=udp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  RTCIceServer(
      url: "turn:vc.cinteraction.com:3478?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  // RTCIceServer(
  //     url: "turn:vc.cinteraction.com:80?transport=tcp",
  //     username: mixTurnServerUsername,
  //     credential: mixTurnServerCredential),
  RTCIceServer(
      url: "turns:vc.cinteraction.com:443?transport=tcp",
      username: mixTurnServerUsername,
      credential: mixTurnServerCredential),
  // RTCIceServer(
  //     url: "turns:vc.cinteraction.com:5349?transport=tcp",
  //     username: mixTurnServerUsername,
  //     credential: mixTurnServerCredential),

  // RTCIceServer(
  //     url: "turn:server.institutonline.ai:55611?transport=udp",
  //     username: "ivi",
  //     credential: "vcnswd321"),
  //
  // RTCIceServer(
  //     url: "turn:server.institutonline.ai:55611?transport=tcp",
  //     username: "ivi",
  //     credential: "vcnswd321"),


  // RTCIceServer(
  //     url: "turn:global.turn.twilio.com:3478?transport=udp",
  //     username: twillioTurnUsername,
  //     credential: twillioTurnPass),
  //
  // RTCIceServer(
  //     url: "turn:global.turn.twilio.com:3478?transport=tcp",
  //     username: twillioTurnUsername,
  //     credential: twillioTurnPass),
  //
  // RTCIceServer(
  //     url: "turn:global.turn.twilio.com:443?transport=tcp",
  //     username: twillioTurnUsername,
  //     credential: twillioTurnPass),
];

String twillioTurnUsername = "2f8f0f5493a884fb0dbd173cc43c3295978e3b9995a982885677cfa334434e96";
String twillioTurnPass = "Dzcv6AOWhKqNo8L/+43coVZiE+I4zL/5+EU32IS3xnA=";




// {
// "room":1234567,
// "description":"this is my room",
// "pin_required":false,
// "is_private":false,
// "max_publishers":100,
// "bitrate":0,
// "fir_freq":0,
// "require_pvtid":false,
// "require_e2ee":false,
// "dummy_publisher":false,
// "notify_joining":false,
// "audiocodec":"opus",
// "videocodec":"vp8",
// "opus_fec":true,
// "record":false,
// "lock_record":false,
// "num_participants":0,
// "audiolevel_ext":true,
// "audiolevel_event":true,
// "audio_active_packets":100,
// "audio_level_average":25,
// "videoorient_ext":true,
// "playoutdelay_ext":true,
// "transport_wide_cc_ext":true
// }
//
//
//
// {
// "room":4800048768,
// "description":"Room 4800048768",
// "pin_required":false,
// "max_publishers":40,
// "bitrate_cap":true,
// "fir_freq":0,
// "require_pvtid":false,
// "require_e2ee":false,
// "dummy_publisher":false,
// "notify_joining":false,
// "audiocodec":"opus",
// "videocodec":"h264",
// "opus_fec":true,
// "record":false,
// "lock_record":false,
// "num_participants":1,
// "audiolevel_ext":true,
// "audiolevel_event":false,
// "videoorient_ext":true,
// "playoutdelay_ext":true,
// "transport_wide_cc_ext":true
// }