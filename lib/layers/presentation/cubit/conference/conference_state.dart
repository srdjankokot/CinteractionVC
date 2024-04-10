import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/util/util.dart';


class ConferenceState extends Equatable {
  final bool isInitial;
  final bool isEnded;
  final Map<dynamic, StreamRenderer>? streamRenderers;
  final List<Participant>? streamSubscribers;
  final bool audioMuted;
  final bool videoMuted;
  final bool engagementEnabled;
  final int? numberOfStreams;
  final int? avgEngagement;
  final int numberOfStreamsCopy;
  final bool isGridLayout;

  const ConferenceState({
    required this.isInitial,
    required this.isEnded,
    this.streamRenderers,
    this.streamSubscribers,
    required this.audioMuted,
    required this.videoMuted,
    required this.engagementEnabled,
    this.numberOfStreams,
    this.avgEngagement,
    required this.numberOfStreamsCopy,
    required this.isGridLayout,
  });


  const ConferenceState.initial({
    bool isInitial = true,
    bool isEnded = false,
    Map<dynamic, StreamRenderer>? streamRenderers,
    bool audioMuted = false,
    bool videoMuted = false,
    bool engagementEnabled = true,
    int? numberOfStreamsCopy,
    int? isGridLayout,
    int? avgEngagement = 0,
  }) : this(isInitial: isInitial, isEnded: isEnded, audioMuted: audioMuted, videoMuted: videoMuted, numberOfStreamsCopy: 1, isGridLayout: true, engagementEnabled: engagementEnabled, avgEngagement: avgEngagement);


  const ConferenceState.ended({
    bool isInitial = false,
    bool isEnded = true,
    Map<dynamic, StreamRenderer>? streamRenderers,
    bool audioMuted = false,
    bool videoMuted = false,
    bool engagementEnabled = true,
  }) : this(isInitial: isInitial, isEnded: isEnded, audioMuted: audioMuted, videoMuted: videoMuted, numberOfStreamsCopy: 1, isGridLayout: true, engagementEnabled : engagementEnabled);


  ConferenceState copyWith({
    bool? isInitial,
    bool? isEnded,
    Map<dynamic, StreamRenderer>? streamRenderers,
    List<Participant>? streamSubscribers,
    int? numberOfStreams,
    int? numberOfStreamsCopy,
    int? avgEngagement,
    bool? audioMuted,
    bool? videoMuted,
    bool? engagementEnabled,
    bool? isGridLayout,
  }) {
    return ConferenceState(
      isInitial: isInitial ?? this.isInitial,
      isEnded: isEnded ?? this.isEnded,
      streamRenderers: streamRenderers ?? this.streamRenderers,
      streamSubscribers: streamSubscribers ?? this.streamSubscribers,
      numberOfStreams: numberOfStreams ?? this.numberOfStreams,
      audioMuted: audioMuted ?? this.audioMuted,
      videoMuted: videoMuted ?? this.videoMuted,
      engagementEnabled: engagementEnabled ?? this.engagementEnabled,
      numberOfStreamsCopy: numberOfStreamsCopy ?? this.numberOfStreamsCopy,
      avgEngagement: avgEngagement ?? this.avgEngagement,
      isGridLayout: isGridLayout ?? this.isGridLayout,
    );
  }

  @override
  List<Object?> get props => [isInitial, isEnded, streamRenderers, streamSubscribers, numberOfStreams, audioMuted, videoMuted, numberOfStreamsCopy, isGridLayout, engagementEnabled, avgEngagement];
}

// @immutable
// sealed class ConferenceState{
//   const ConferenceState({this.audioMuted = false});
//   final bool? audioMuted;
//
//   bool? get audioMute => audioMuted;
// }
//
//
// class ConferenceInitial extends ConferenceState{
//   const ConferenceInitial();
// }
//
// class ConferenceEnd extends ConferenceState{
//   const ConferenceEnd();
// }
//
//
// class ConferenceInProgress extends ConferenceState{
//   @override
//   final bool audioMuted;
//
//   final Map<dynamic, StreamRenderer>? streamRenderers;
//
//   const ConferenceInProgress({required this.streamRenderers, required this.audioMuted});
// }