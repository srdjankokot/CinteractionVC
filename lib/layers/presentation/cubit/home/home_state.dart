part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({this.scheduleStartDateTime, required this.loading, this.nextMeeting});

  @override
  List<Object?> get props => [scheduleStartDateTime, loading, nextMeeting];

  final DateTime? scheduleStartDateTime;
  final bool loading;
  final Meeting? nextMeeting;

  const HomeState.initial({
    DateTime? scheduleDate,
    TimeOfDay? scheduleTime,
  }) : this(
      scheduleStartDateTime: scheduleDate,
      loading: false);

HomeState copyWith({DateTime? scheduleDate, TimeOfDay? scheduleTime, bool? loading, Meeting? nextMeeting}) {
  return HomeState(
      scheduleStartDateTime: scheduleDate ?? scheduleStartDateTime,
      loading: loading?? false,
      nextMeeting: nextMeeting?? this.nextMeeting);
}}
