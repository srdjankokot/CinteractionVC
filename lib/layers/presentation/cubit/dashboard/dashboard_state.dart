part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  DashboardState(
      {this.loading,
      this.meetingAttendedSum,
      this.realizedMeetings,
      this.missedMeetings,
      required this.meetingAttended,
      this.avgDurationPerSession,
      this.avgUsersPerMeeting,
      required this.usersPerMeeting,
      required this.durationsPerSession});

  @override
  List<Object?> get props =>
      [loading, meetingAttendedSum, durationsPerSession, usersPerMeeting];

  final bool? loading;
  final int? meetingAttendedSum;
  final int? realizedMeetings;
  final int? missedMeetings;
  List<double> meetingAttended = List.empty();

  final int? avgUsersPerMeeting;
  List<double> usersPerMeeting = List.empty();

  final int? avgDurationPerSession;
  List<double> durationsPerSession = List.empty();

  DashboardState.initial(
      {bool loading = false,
      required List<double> meetingAttended,
      required List<double> usersPerMeeting,
      required List<double> durationsPerSession})
      : this(
            loading: loading,
            meetingAttended: meetingAttended,
            usersPerMeeting: usersPerMeeting,
            durationsPerSession: durationsPerSession);

  DashboardState copyWith(
      {bool? loading,
      int? meetingAttendedSum,
      int? realizedMeetings,
      int? missedMeetings,
      int? avgUsersPerMeeting,
      int? avgDurationPerSession,
      List<double>? meetingAttended,
      List<double>? usersPerMeeting,
      List<double>? durationsPerSession}) {
    return DashboardState(
      loading: loading,
      meetingAttendedSum: meetingAttendedSum ?? this.meetingAttendedSum,
      realizedMeetings: realizedMeetings ?? this.realizedMeetings,
      missedMeetings: missedMeetings ?? this.missedMeetings,
      avgUsersPerMeeting: avgUsersPerMeeting ?? this.avgUsersPerMeeting,
      usersPerMeeting: usersPerMeeting ?? this.usersPerMeeting,
      meetingAttended: meetingAttended ?? this.meetingAttended,
      durationsPerSession: durationsPerSession ?? this.durationsPerSession,
    );
  }
}
