import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/layers/domain/entities/api_error.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/util/util.dart';
import '../../../domain/entities/chat_message.dart';


class ConferenceState extends Equatable {
  final bool isInitial;
  final bool isEnded;
  final Map<dynamic, StreamRenderer>? streamRenderers;
  final List<Participant>? streamSubscribers;
  final List<ChatMessage>? messages;
  final bool audioMuted;
  final bool videoMuted;
  final bool screenShared;
  final bool engagementEnabled;
  final bool showingChat;
  final int? numberOfStreams;
  final int? avgEngagement;
  final int numberOfStreamsCopy;
  final bool isGridLayout;
  final String? error;

  const ConferenceState({
    required this.isInitial,
    required this.isEnded,
    this.streamRenderers,
    this.streamSubscribers,
    this.messages,
    required this.audioMuted,
    required this.videoMuted,
    required this.screenShared,
    required this.engagementEnabled,
    required this.showingChat,
    this.numberOfStreams,
    this.avgEngagement,
    required this.numberOfStreamsCopy,
    required this.isGridLayout,
    this.error,

  });


  const ConferenceState.initial({
    bool isInitial = true,
    bool isEnded = false,
    Map<dynamic, StreamRenderer>? streamRenderers,
    bool audioMuted = false,
    bool videoMuted = false,
    bool screenShared = false,
    bool engagementEnabled = true,
    bool showingChat = false,
    int? numberOfStreamsCopy,
    int? isGridLayout,
    int? avgEngagement = 0,
  }) : this(isInitial: isInitial, isEnded: isEnded, audioMuted: audioMuted, videoMuted: videoMuted, numberOfStreamsCopy: 1, isGridLayout: true, engagementEnabled: engagementEnabled, avgEngagement: avgEngagement, screenShared:screenShared, showingChat: showingChat);


  const ConferenceState.ended({
    bool isInitial = false,
    bool isEnded = true,
    Map<dynamic, StreamRenderer>? streamRenderers,
    bool audioMuted = false,
    bool videoMuted = false,
    bool screenShared = false,
    bool engagementEnabled = true,
    bool showingChat = false,
  }) : this(isInitial: isInitial, isEnded: isEnded, audioMuted: audioMuted, videoMuted: videoMuted, numberOfStreamsCopy: 1, isGridLayout: true, engagementEnabled : engagementEnabled, screenShared:screenShared, showingChat:showingChat);


  const ConferenceState.error({
    bool isInitial = false,
    bool isEnded = true,
    Map<dynamic, StreamRenderer>? streamRenderers,
    bool audioMuted = false,
    bool videoMuted = false,
    bool screenShared = false,
    bool engagementEnabled = true,
    bool showingChat = false,
    required String error,
  }) : this(isInitial: isInitial, isEnded: isEnded, audioMuted: audioMuted, videoMuted: videoMuted, numberOfStreamsCopy: 1, isGridLayout: true, engagementEnabled : engagementEnabled, screenShared:screenShared, error: error, showingChat:showingChat);




  ConferenceState copyWith({
    bool? isInitial,
    bool? isEnded,
    Map<dynamic, StreamRenderer>? streamRenderers,
    List<Participant>? streamSubscribers,
    List<ChatMessage>? messages,
    int? numberOfStreams,
    int? numberOfStreamsCopy,
    int? avgEngagement,
    bool? audioMuted,
    bool? videoMuted,
    bool? screenShared,
    bool? engagementEnabled,
    bool? showingChat,
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
      screenShared: screenShared ?? this.screenShared,
      engagementEnabled: engagementEnabled ?? this.engagementEnabled,
      numberOfStreamsCopy: numberOfStreamsCopy ?? this.numberOfStreamsCopy,
      avgEngagement: avgEngagement ?? this.avgEngagement,
      isGridLayout: isGridLayout ?? this.isGridLayout,
      showingChat: showingChat ?? this.showingChat,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [isInitial, isEnded, streamRenderers, streamSubscribers, numberOfStreams, audioMuted, videoMuted, numberOfStreamsCopy, isGridLayout, engagementEnabled, avgEngagement, screenShared, showingChat, messages];
}