import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/features/conference/provider/conference_provider.dart';
import 'package:cinteraction_vc/util.dart';
import 'package:janus_client/janus_client.dart';

class ConferenceRepository
{
  ConferenceRepository({required this.provider});

  final ConferenceProvider provider;


  Future<void> initialize(int roomId, String displayName) async{
    provider.initialize(roomId, displayName);
  }

  Stream<Map<dynamic, StreamRenderer>> getStreamRendererStream()
  {
    return provider.getConferenceStream();
  }

  Stream<String> getConferenceEndedStream()
  {
    return provider.getConferenceEndedStream();
  }

  Stream<List<Participant>> getSubscribersStream()
  {
    return provider.getParticipantStream();
  }

  Future<void> finishCall() async
  {
    return provider.callEnd('User hanged');
  }

  Future<void> mute(String type, bool enabled) async
  {
    await provider.mute(type, enabled);
  }

  Future<void> changeSubstream(String remoteStreamId, int substream) async
  {
    return provider.changeSubstream(remoteStreamId, substream);
  }

  Future<void> kick(String id) async
  {
    provider.kick(id);
  }

  Future<void> unpublish() async{
    provider.unPublish();
  }

  Future<void> publish() async{
    provider.publish();
  }

  Future<void> ping(String msg) async{
    provider.ping(msg);
  }

  Future<void> getParticipants() async{
    provider.getParticipants();
  }

  Future<void> switchCamera() async{
    provider.switchCamera();
  }

  Future<void> unPublishById(String id) async{
    provider.unPublishById(id);
  }

  Future<void> publishById(String id) async{
    provider.publishById(id);
  }

  Future<void> changeSubStream(ConfigureStreamQuality quality) async
  {
    provider.changeSubStreamToAll(quality);
  }

}