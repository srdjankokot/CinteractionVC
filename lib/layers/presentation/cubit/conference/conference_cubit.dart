import 'dart:async';
import 'dart:math';

import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/domain/usecases/conference/conference_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:janus_client/janus_client.dart';

import '../../../../core/logger/loggy_types.dart';
import 'conference_state.dart';

class ConferenceCubit extends Cubit<ConferenceState> with BlocLoggy {
  ConferenceCubit(
      {required this.conferenceUseCases,
      required this.roomId,
      required this.displayName})
      : super(const ConferenceState.initial()) {
    _load();
  }

  final int roomId;
  final String displayName;
  final ConferenceUseCases conferenceUseCases;

  StreamSubscription<Map<dynamic, StreamRenderer>>? _conferenceSubscription;
  StreamSubscription<String>? _conferenceEndedStream;
  StreamSubscription<List<Participant>>? _subscribersStream;

  void _load() async {
    await conferenceUseCases.conferenceInitialize
        .call(displayName: displayName, roomId: roomId);
    _conferenceSubscription =
        conferenceUseCases.getRendererStream().listen(_onConference);
    _conferenceEndedStream =
        conferenceUseCases.getEndStream().listen(_onConferenceEnded);
    _subscribersStream =
        conferenceUseCases.getSubscriberStream().listen(_onSubscribers);
  }

  @override
  Future<void> close() {
    _conferenceSubscription?.cancel();
    _conferenceEndedStream?.cancel();
    _subscribersStream?.cancel();

    return super.close();
  }

  Future<void> finishCall() async {
    loggy.info('finish call button clicked');
    // conferenceRepository.finishCall().then((value) =>  emit(const ConferenceState.ended()));
    conferenceUseCases.finishCall();
  }

  // bool audioMuted = false;
  // final Map<dynamic, StreamRenderer> streamRenderers = {};

  Future<void> audioMute() async {
    var mute = state.audioMuted;
    await conferenceUseCases.mute('audio', !mute);
    emit(state.copyWith(audioMuted: !mute));
  }

  Future<void> videoMute() async {
    var muted = state.videoMuted;
    await conferenceUseCases.mute('video', !muted);
    emit(state.copyWith(videoMuted: !muted));
  }

  Future<void> toggleEngagement() async {
    var enabled = state.engagementEnabled;
    await conferenceUseCases.toggleEngagement(!enabled);
    emit(state.copyWith(engagementEnabled: !enabled));
  }

  //Listening streams methods
  void _onConference(Map<dynamic, StreamRenderer> streams) {
    loggy.info('list of streams: ${streams.length}');
    // Map<dynamic, StreamRenderer> s = streams;
    emit(state.copyWith(
        isInitial: false,
        streamRenderers: streams));
    conferenceUseCases.getParticipants();
  }

  void _onConferenceEnded(String reason) {
    loggy.info('call ended with reason: $reason');
    emit(const ConferenceState.ended());
  }

  void _onSubscribers(List<Participant> subscribers) {
    emit(state.copyWith(
        isInitial: false,
        streamSubscribers: subscribers,
        numberOfStreams: Random().nextInt(10000)));
  }

  Future<void> increaseNumberOfCopies() async {
    var copies = state.numberOfStreamsCopy + 1;
    emit(state.copyWith(numberOfStreamsCopy: copies));
  }

  Future<void> decreaseNumberOfCopies() async {
    var copies = state.numberOfStreamsCopy - 1;

    if (copies <= 0) {
      copies = 1;
    }
    emit(state.copyWith(numberOfStreamsCopy: copies));
  }

  void changeLayout() async {
    emit(state.copyWith(isGridLayout: !state.isGridLayout));
  }

  Future<void> kick(String id) async {
    conferenceUseCases.kick(id);
  }

  Future<void> unpublish() async {
    conferenceUseCases.unPublish();
  }

  Future<void> ping(String msg) async {
    conferenceUseCases.ping(msg);
  }

  Future<void> publish() async {
    conferenceUseCases.publish();
  }

  Future<void> getParticipants() async {
    conferenceUseCases.getParticipants();
  }

  Future<void> switchCamera() async {
    conferenceUseCases.switchCamera();
  }

  Future<void> unPublishById(String id) async {
    conferenceUseCases.unPublishById(id);
  }

  Future<void> publishById(String id) async {
    conferenceUseCases.publishById(id);
  }

  Future<void> changeSubStream(ConfigureStreamQuality quality) async {
    conferenceUseCases.changeSubStream(quality);
  }


}
