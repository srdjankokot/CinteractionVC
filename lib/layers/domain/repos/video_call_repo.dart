import 'package:webrtc_interface/webrtc_interface.dart';

abstract class VideoCallRepo{
  const VideoCallRepo();

  Future<void> initialize();
  Future<void> makeCall(String user);
  Future<void> answerCall(String caller, RTCSessionDescription? jsep);
  Future<void> rejectCall();
  Stream<String> incomingCall();

}