
import 'package:flutter_bloc/flutter_bloc.dart';

import 'conference_event.dart';
import 'conference_state.dart';

class ConferenceBloc extends Bloc<ConferenceEvents, ConferenceStates>{

  bool audioMute = false;

  ConferenceBloc() : super(InitialState()){
    on<MuteAudioEvent>(onAudioMute);
    on<UnMuteAudioEvent>(onAudioUnMute);
  }

  void onAudioMute(MuteAudioEvent event, Emitter<ConferenceStates> emit) async {
    audioMute = true;
    emit(AudioMuteState(audioMute));
  }

  void onAudioUnMute(UnMuteAudioEvent event, Emitter<ConferenceStates> emit) async {
    audioMute = false;
    emit(AudioMuteState(audioMute));
  }
}