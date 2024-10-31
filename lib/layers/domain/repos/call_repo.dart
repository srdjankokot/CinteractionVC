import '../../../core/util/util.dart';

abstract class CallRepo
{
  const CallRepo();

  Future<void> initialize();

  Future<void> makeCall(String user);
  Future<void> answerCall();
  Future<void> rejectCall();
  Stream<String> getVideoCallStream();
  Stream<StreamRenderer> getLocalStream();
  Stream<StreamRenderer> getRemoteStream();

}