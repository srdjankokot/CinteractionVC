import 'dart:async';
import 'dart:math';

import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/core/util/util.dart';
import 'package:cinteraction_vc/layers/domain/usecases/conference/conference_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:janus_client/janus_client.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../../core/logger/loggy_types.dart';
import '../../../domain/entities/chat_message.dart';
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
  StreamSubscription<List<ChatMessage>>? _conferenceMessageStream;
  StreamSubscription<List<Participant>>? _subscribersStream;
  StreamSubscription<int>? _avgEngagementStream;

  void _load() async {
    await conferenceUseCases.conferenceInitialize(
        displayName: displayName, roomId: roomId);
    _conferenceSubscription =
        conferenceUseCases.getRendererStream().listen(_onConference);
    _conferenceEndedStream =
        conferenceUseCases.getEndStream().listen(_onConferenceEnded);
    _subscribersStream =
        conferenceUseCases.getSubscriberStream().listen(_onSubscribers);

    _conferenceMessageStream =
        conferenceUseCases.getMessageStream().listen(_onMessageReceived);

    _avgEngagementStream = conferenceUseCases
        .getAvgEngagementStream()
        .listen(_onEngagementChanged);

    var startCall = await conferenceUseCases.startCall();

    if (startCall.error != null) {
      emit(ConferenceState.error(error: startCall.error!.errorMessage));
      return;
    }
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

  Future<void> toggleChatWindow() async {
    emit(state.copyWith(showingChat: !state.showingChat));
  }

  Future<void> chatMessageSeen(int index) async {
    state.messages![index].seen = true;
    emit(state.copyWith(
        unreadMessages: state.messages!
            .where((element) => !(element.seen ?? true))
            .length));
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
    // loggy.info('list of streams: ${streams.length}');
    // Map<dynamic, StreamRenderer> s = streams;
    emit(state.copyWith(isInitial: false, streamRenderers: streams));
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

  void _onMessageReceived(List<ChatMessage> chat) {
    emit(state.copyWith(
        messages: chat,
        numberOfStreams: Random().nextInt(10000),
        unreadMessages:
            chat.where((element) => !(element.seen ?? true)).length));
  }

  void _onEngagementChanged(int avgEngagement) {
    emit(state.copyWith(isInitial: false, avgEngagement: avgEngagement));
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

  Future<void> shareScreen(MediaStream? mediaStream) async {
    var screenShared = state.screenShared;

    conferenceUseCases.shareScreen(mediaStream);

    emit(state.copyWith(screenShared: !screenShared));
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

  Future<void> changeSubStream(
      ConfigureStreamQuality quality, StreamRenderer remoteStream) async {
    conferenceUseCases.changeSubStream(quality, remoteStream);
  }

  Future<void> sendMessage(String msg) async {
    conferenceUseCases.sendMessage(msg);
  }

  Future<void> recordingMeet() async {
    if (state.recording == RecordingStatus.notRecording) {
       // bool recording = await FlutterScreenRecording.startRecordScreenAndAudio("videoName");
        emit(state.copyWith(recording: RecordingStatus.loading));
       var recordingStarted = await conferenceUseCases.startRecording();
       emit(state.copyWith(recording: recordingStarted ? RecordingStatus.recording: RecordingStatus.notRecording));
    } else {
      // FlutterScreenRecording.stopRecordScreen;
      conferenceUseCases.stopRecording();


      emit(state.copyWith(recording: RecordingStatus.notRecording));
    }
  }
}
