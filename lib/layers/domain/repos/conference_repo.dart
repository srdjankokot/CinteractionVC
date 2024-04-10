import 'dart:async';

import 'package:janus_client/janus_client.dart';

import '../../../core/io/network/models/participant.dart';
import '../../../core/util/util.dart';

abstract class ConferenceRepo{
  const ConferenceRepo();


  Future<void> initialize({required int roomId, required String displayName});

  Stream<Map<dynamic, StreamRenderer>> getStreamRendererStream();

  Stream<String> getConferenceEndedStream();

  Stream<List<Participant>> getSubscribersStream();

  Stream<int> getAvgEngagementStream();

  Future<void> finishCall();

  Future<void> mute({required String kind, required bool muted});

  Future<void> changeSubstream({required String remoteStreamId, required int substream});
  Future<void> kick({required String id});

  Future<void> unPublish();

  Future<void> publish();

  Future<void> ping({required String msg});

  Future<void> toggleEngagement({required bool enabled});

  Future<List<Participant>> getParticipants();

  Future<void> switchCamera();

  Future<void> unPublishById({required String id});

  Future<void> publishById({required String id});

  Future<void> changeSubStream({required ConfigureStreamQuality quality});

}