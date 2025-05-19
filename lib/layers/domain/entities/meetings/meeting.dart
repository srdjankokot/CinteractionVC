import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

class Meeting {
  Meeting(
      {required this.callId,
      this.chatId,
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
  int? chatId;

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

  @JsonKey(name: 'event_name')
  String? eventName;


  @JsonKey(name: 'meeting_start')
  DateTime meetingStart;

  @JsonKey(name: 'meeting_end')
  DateTime? meetingEnd;


  String formatMeetingDuration() {
    if (meetingEnd == null) return '';

    final duration = meetingEnd!.difference(meetingStart);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}'
          '${minutes > 0 ? ' $minutes minute${minutes > 1 ? 's' : ''}' : ''}';
    } else {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
  }



}
