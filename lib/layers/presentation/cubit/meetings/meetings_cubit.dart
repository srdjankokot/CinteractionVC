import 'dart:async';

import 'package:cinteraction_vc/core/logger/loggy_types.dart';
import 'package:cinteraction_vc/layers/domain/usecases/meeting/meeting_use_cases.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/meeting.dart';

part 'meetings_state.dart';

class MeetingCubit extends Cubit<MeetingState> with BlocLoggy {
  MeetingCubit({
    required this.meetingUseCases,
  }) : super(const InitialRoleState()) {
    _load();
  }

  final MeetingUseCases meetingUseCases;

  // StreamSubscription<List<Meeting>?>? _meetingSubscription;

  @override
  Future<void> close() {
    // _meetingSubscription?.cancel();
    return super.close();
  }

  void _load() {
    // _meetingSubscription = meetingUseCases.getMeetingStream().listen(_onGroups);
  }

  void loadMeetings() async {
    emit(const MeetingsIsLoading());
    var meetings = await meetingUseCases.getPastMeetingsUseCase();
    if (meetings.error == null) {
      emit(MeetingLoaded(meetings: meetings.response ?? List.empty()));
    } else {
      emit(MeetingLoaded(meetings: List.empty()));

    }
  }

  void loadScheduledMeetings() async {
    emit(const MeetingsIsLoading());
    var meetings = await meetingUseCases.getScheduleMeetings();

    if (meetings.error == null) {
      emit(MeetingLoaded(meetings: meetings.response ?? List.empty()));
    } else {
      emit(MeetingLoaded(meetings: List.empty()));
    }
  }

  void _onGroups(List<Meeting> meetings) {
    loggy.info('list of meetings: ${meetings?.length}');
    emit(MeetingLoaded(meetings: meetings));
  }

  Future<void> addRole() async {
    // emit(const MeetingsIsLoading());
    // meetingRepository.addMeeting();
  }
}
