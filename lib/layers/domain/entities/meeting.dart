import 'package:json_annotation/json_annotation.dart';

class Meeting {
  Meeting(
      {
        required this.callId,
      required this.organizerId,
      required this.organizer,
      required this.averageEngagement,
      required this.totalNumberOfUsers,
      required this.recorded,
      required this.meetingStart,
       this.meetingEnd});

  @JsonKey(name: 'call_id')
  int callId;

  @JsonKey(name: 'organizer_id')
  int organizerId;

  String organizer;

  @JsonKey(name: 'average_engagement')
  double averageEngagement;

  @JsonKey(name: 'total_number_of_users')
  int totalNumberOfUsers;

  bool recorded;

  @JsonKey(name: 'meeting_start')
  DateTime meetingStart;

  @JsonKey(name: 'meeting_end')
  DateTime? meetingEnd;
}
