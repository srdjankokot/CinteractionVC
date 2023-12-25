class ConferenceStates {}

class InitialState extends ConferenceStates {}

class AudioMuteState extends ConferenceStates {
  final bool audioMuted;

  AudioMuteState(this.audioMuted);
}

class VideoMuteState extends ConferenceStates {
  final bool videoMuted;

  VideoMuteState(this.videoMuted);
}

