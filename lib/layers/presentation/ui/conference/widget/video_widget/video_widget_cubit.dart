import 'package:cinteraction_vc/layers/presentation/ui/conference/widget/video_widget/video_widget_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/util/util.dart';

class VideoWidgetCubit extends Cubit<VideoWidgetState> {

  VideoWidgetCubit(double width, double height, StreamRenderer videoRenderer) : super(VideoWidgetState.initial(width, height, videoRenderer)) {
    load();
  }

  void load(){

  }

  void updateAudioMute(bool isMuted) {
    emit(state.copyWith(audioMuted: isMuted));
  }
  void updateVideoMute(bool isMuted) {
    emit(state.copyWith(videoMuted: isMuted));
  }

  void updateVideoFlowing(bool flowing) {
    emit(state.copyWith(isVideoFlowing: flowing));
  }

  void updateSpeaking(bool isSpeaking) {
    emit(state.copyWith(isSpeaking: isSpeaking));
  }

}