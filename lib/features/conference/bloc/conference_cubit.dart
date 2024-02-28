import 'dart:async';
import 'dart:math';

import 'package:cinteraction_vc/features/conference/bloc/conference_state.dart';
import 'package:cinteraction_vc/features/conference/repository/conference_repository.dart';
import 'package:cinteraction_vc/util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/logger/loggy_types.dart';

class ConferenceCubit extends Cubit<ConferenceState> with BlocLoggy {

  ConferenceCubit({required this.conferenceRepository,}) : super( const ConferenceState.initial()) {
    _load();
  }

  final ConferenceRepository conferenceRepository;
  StreamSubscription<Map<dynamic, StreamRenderer>>? _conferenceSubscription;
  StreamSubscription<String>? _conferenceEndedStream;

  void _load() {
    conferenceRepository.initialize();
    _conferenceSubscription = conferenceRepository.getStreamRendererStream().listen(_onConference);
    _conferenceEndedStream = conferenceRepository.getConferenceEndedStream().listen(_onConferenceEnded);
  }

  @override
  Future<void> close() {
    _conferenceSubscription?.cancel();
    return super.close();
  }

  Future<void> finishCall() async {
    loggy.info('finish call button clicked');
    // conferenceRepository.finishCall().then((value) =>  emit(const ConferenceState.ended()));
    conferenceRepository.finishCall();
  }



  // bool audioMuted = false;
  // final Map<dynamic, StreamRenderer> streamRenderers = {};

  Future<void> audioMute() async
  {
    var mute = state.audioMuted;
    await conferenceRepository.mute('audio', !mute);
    emit(state.copyWith(audioMuted: !mute));
  }

  Future<void> videoMute() async
  {
    var muted = state.videoMuted;
    await conferenceRepository.mute('video',  !muted);
    emit(state.copyWith(videoMuted:  !muted));
  }

  Future<void> changeSubstream(String remoteStreamId, int substream) async
  {
    return conferenceRepository.changeSubstream(remoteStreamId, substream);
  }

  //Listening streams methods
  void _onConference(Map<dynamic, StreamRenderer> streams) {
    loggy.info('list of streams: ${streams.length}');
    Map<dynamic, StreamRenderer> s = streams;
    emit(state.copyWith(isInitial: false, streamRenderers: s, numberOfStreams: Random().nextInt(10000)));
  }

  void _onConferenceEnded(String reason) {
    loggy.info('call ended with reason: $reason');
    emit(const ConferenceState.ended());
  }

  Future<void> increaseNumberOfCopies() async{
    var copies = state.numberOfStreamsCopy + 1;
    emit(state.copyWith(numberOfStreamsCopy: copies));
  }

  Future<void> decreaseNumberOfCopies() async{
    var copies = state.numberOfStreamsCopy - 1;

    if(copies<=0) {
      copies = 1;
    }
    emit(state.copyWith(numberOfStreamsCopy: copies));
  }

  void changeLayout() async{
    emit(state.copyWith(isGridLayout: !state.isGridLayout));
  }

  Future<void> kick(String id) async
  {
    conferenceRepository.kick(id);
  }

  Future<void> unpublish() async{
    conferenceRepository.unpublish();
  }

  Future<void> publish() async{
    conferenceRepository.publish();
  }
  Future<void> getParticipants() async{
    conferenceRepository.getParticipants();
  }


}