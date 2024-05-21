
import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/dashboard/session_meeting.dart';


@JsonSerializable(explicitToJson: true)
class SessionMeetingDto extends SessionMeeting{
  SessionMeetingDto(
      {required super.meetingId,
      required super.duration,
      required super.averageEngagement,
      required super.users,
      required super.date});


  @override
  factory SessionMeetingDto.fromJson(Map<String, dynamic> json) {
    var meetings = json["meetings"];

    return SessionMeetingDto(
      averageEngagement: json['avg_engagement'] as double,
      date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
      users: json['users'] as int,
      duration: json['duration'] as int,
      meetingId:  json['meeting_id'] as int,);
  }
}
