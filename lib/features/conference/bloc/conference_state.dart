import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../util.dart';

class ConferenceState extends Equatable {
  final bool isInitial;
  final bool isEnded;
  final Map<dynamic, StreamRenderer>? streamRenderers;
  final List<Participant>? streamSubscribers;
  final bool audioMuted;
  final bool videoMuted;
  final int? numberOfStreams;
  final int numberOfStreamsCopy;
  final bool isGridLayout;

  const ConferenceState({
    required this.isInitial,
    required this.isEnded,
    this.streamRenderers,
    this.streamSubscribers,
    required this.audioMuted,
    required this.videoMuted,
    this.numberOfStreams,
    required this.numberOfStreamsCopy,
    required this.isGridLayout,
  });


  const ConferenceState.initial({
    bool isInitial = true,
    bool isEnded = false,
    Map<dynamic, StreamRenderer>? streamRenderers,
    bool audioMuted = false,
    bool videoMuted = false,
    int? numberOfStreamsCopy,
    int? isGridLayout,
  }) : this(isInitial: isInitial, isEnded: isEnded, audioMuted: audioMuted, videoMuted: videoMuted, numberOfStreamsCopy: 1, isGridLayout: true);


  const ConferenceState.ended({
    bool isInitial = false,
    bool isEnded = true,
    Map<dynamic, StreamRenderer>? streamRenderers,
    bool audioMuted = false,
    bool videoMuted = false,
  }) : this(isInitial: isInitial, isEnded: isEnded, audioMuted: audioMuted, videoMuted: videoMuted, numberOfStreamsCopy: 1, isGridLayout: true);


  ConferenceState copyWith({
    bool? isInitial,
    bool? isEnded,
    Map<dynamic, StreamRenderer>? streamRenderers,
    List<Participant>? streamSubscribers,
    int? numberOfStreams,
    int? numberOfStreamsCopy,
    bool? audioMuted,
    bool? videoMuted,
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
      numberOfStreamsCopy: numberOfStreamsCopy ?? this.numberOfStreamsCopy,
      isGridLayout: isGridLayout ?? this.isGridLayout,
    );
  }

  @override
  List<Object?> get props => [isInitial, isEnded, streamRenderers, streamSubscribers, numberOfStreams, audioMuted, videoMuted, numberOfStreamsCopy, isGridLayout];
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