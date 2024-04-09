

import 'package:json_annotation/json_annotation.dart';

import 'meeting.dart';
part 'meeting_response.g.dart';

@JsonSerializable()
class MeetingResponse {

  MeetingResponse({required this.pastMeetings, required this.scheduleMeetings});
  List<Meeting> pastMeetings;
  List<Meeting> scheduleMeetings;


  factory MeetingResponse.fromJson(Map<String, dynamic> json) => _$MeetingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MeetingResponseToJson(this);
}