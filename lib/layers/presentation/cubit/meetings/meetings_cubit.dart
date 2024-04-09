import 'dart:async';

import 'package:cinteraction_vc/core/logger/loggy_types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../ui/meetings/model/meeting.dart';
import '../../ui/meetings/repository/meetings_repository.dart';

part 'meetings_state.dart';

class MeetingCubit extends Cubit<MeetingState> with BlocLoggy{
  MeetingCubit({
    required this.meetingRepository,
  }) : super(const InitialRoleState()) {
    _load();
  }

  final MeetingRepository meetingRepository;

  StreamSubscription<List<Meeting>?>? _meetingSubscription;


  @override
  Future<void> close() {
    _meetingSubscription?.cancel();
    return super.close();
  }


  void _load() {
    _meetingSubscription = meetingRepository.getMeetingStream().listen(_onGroups);
  }

  void loadMeetings() {
    emit(const MeetingsIsLoading());
    meetingRepository.getListOfMeetings();
  }

  void loadScheduledMeetings() {
    emit(const MeetingsIsLoading());
    meetingRepository.getListOfScheduledMeetings();
  }


  void _onGroups(List<Meeting> meetings) {
    loggy.info('list of meetings: ${meetings?.length}');
    emit(MeetingLoaded(meetings: meetings));
  }

  Future<void> addRole() async {
    emit(const MeetingsIsLoading());
    meetingRepository.addMeeting();
  }


}