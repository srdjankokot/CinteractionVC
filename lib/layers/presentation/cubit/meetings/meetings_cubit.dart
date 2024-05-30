import 'package:cinteraction_vc/core/logger/loggy_types.dart';
import 'package:cinteraction_vc/layers/domain/usecases/meeting/meeting_use_cases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/meeting.dart';

part 'meetings_state.dart';

class MeetingCubit extends Cubit<MeetingState> with BlocLoggy {
  MeetingCubit({
    required this.meetingUseCases,
  }) : super(const MeetingState.initial()) {
    _load();
  }

  final MeetingUseCases meetingUseCases;

  void _load() {
    loadMeetings();
  }

  void loadMeetings() async {
    emit(state.copyWith(isLoading: true));
    var meetings = await meetingUseCases.getPastMeetingsUseCase();
    if (meetings.error == null) {
      emit(state.copyWith(meetings: meetings.response ?? List.empty()));
    } else {
      emit(state.copyWith(meetings: List.empty()));
    }
  }

  void loadScheduledMeetings() async {
    emit(state.copyWith(isLoading: true));
    var meetings = await meetingUseCases.getScheduleMeetings();

    if (meetings.error == null) {
      emit(state.copyWith(meetings: meetings.response ?? List.empty()));
    } else {
      emit(state.copyWith(meetings: List.empty()));
    }
  }

  void tabChanged()
  {
    emit(state.copyWith(isShowingPastMeetings: !state.isShowingPastMeetings));
  }
}
