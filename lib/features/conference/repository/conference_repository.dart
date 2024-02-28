import 'package:cinteraction_vc/features/conference/provider/conference_provider.dart';
import 'package:cinteraction_vc/util.dart';

class ConferenceRepository
{
  ConferenceRepository({required this.provider});

  final ConferenceProvider provider;


  Future<void> initialize() async{
    provider.initialize();
  }

  Stream<Map<dynamic, StreamRenderer>> getStreamRendererStream()
  {
    return provider.getConferenceStream();
  }

  Stream<String> getConferenceEndedStream()
  {
    return provider.getConferenceEndedStream();
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
    provider.unpublish();
  }

  Future<void> publish() async{
    provider.publish();
  }

  Future<void> getParticipants() async{
    provider.getParticipants();
  }
}