import 'package:cinteraction_vc/layers/domain/entities/api_response.dart';
import 'package:cinteraction_vc/layers/domain/usecases/home/home_use_cases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/logger/loggy_types.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/meetings/meeting.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> with BlocLoggy {
  HomeCubit({required this.homeUseCases}) : super( HomeState.initial(scheduleDate: DateTime.now().copyWith(minute: 0).add(const Duration(hours: 2)))) {
    init();
  }

  final HomeUseCases homeUseCases;

  void init() {
    getNextMeeting();
  }

  void getNextMeeting() async {
    emit(state.copyWith(loading: true));
    var response = await homeUseCases.getNextMeetingUseCase();
    emit(state.copyWith(nextMeeting: response.response, loading: false));
  }

  void setScheduleDate(DateTime date) {
    emit(state.copyWith(scheduleDate: date));
  }

  void setScheduleTime(TimeOfDay? timeOfDay) {
    emit(state.copyWith(scheduleDate: state.scheduleStartDateTime?.copyWith(hour: timeOfDay?.hour,  minute: timeOfDay?.minute)));
  }

  Future<ApiResponse<String>> scheduleMeeting(String name, String desc, String tag) async {
    emit(state.copyWith(loading: true));
    var response = await homeUseCases.scheduleMeetingUseCase(name, desc, tag, state.scheduleStartDateTime!);
    emit(state.copyWith(loading: false));
    getNextMeeting();

    return response;
  }
}
