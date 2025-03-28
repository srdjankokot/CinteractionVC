import 'package:json_annotation/json_annotation.dart';

class Meeting {
  Meeting(
      {
        required this.callId,
        required this.chatId,
      required this.organizerId,
      required this.organizer,
      this.averageEngagement,
      this.totalNumberOfUsers,
      this.recorded,
      required this.meetingStart,
      this.meetingEnd,
      this.streamId,
      this.eventName});

  @JsonKey(name: 'meeting_id')
  int callId;

  @JsonKey(name: 'chat_id')
  int chatId;

  @JsonKey(name: 'organizer_id')
  int organizerId;

  String organizer;

  @JsonKey(name: 'stream_id')
  String? streamId;

  @JsonKey(name: 'average_engagement')
  double? averageEngagement;

  @JsonKey(name: 'total_number_of_users')
  int? totalNumberOfUsers;

  bool? recorded;

  @JsonKey(name: 'meeting_start')
  DateTime meetingStart;

  @JsonKey(name: 'meeting_end')
  DateTime? meetingEnd;

  @JsonKey(name: 'event_name')
  String? eventName;
}
