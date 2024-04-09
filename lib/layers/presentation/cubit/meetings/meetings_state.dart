part of 'meetings_cubit.dart';

@immutable
sealed class MeetingState{
  const MeetingState();
}

class InitialRoleState extends MeetingState{
  const InitialRoleState();
}

class MeetingLoaded extends MeetingState{
  const MeetingLoaded({required this.meetings});
  final List<Meeting> meetings;
}


class MeetingsIsLoading extends MeetingState{
  const MeetingsIsLoading();
}

