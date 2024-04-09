import 'package:json_annotation/json_annotation.dart';

import '../../../../data/dto/user_dto.dart';

part 'meeting.g.dart';

@JsonSerializable()
class Meeting {
  Meeting({
    required this.id,
    required this.name,
    this.passcode,
    required this.organizer,
    required this.users,
    required this.avgEngagement,
    required this.recorded,
    required this.start,
    required this.end,

  });


   bool recorded;
   int id;

  @JsonKey(name: 'event_name')
  String name;

  String? passcode;

  UserDto organizer;

  @JsonKey(name: 'average_engagement')
  int avgEngagement;

  List<UserDto>users;

  @JsonKey(name: 'meeting_start')
  DateTime start;

  @JsonKey(name: 'meeting_end')
  DateTime end;

  factory Meeting.fromJson(Map<String, dynamic> json) => _$MeetingFromJson(json);
  Map<String, dynamic> toJson() => _$MeetingToJson(this);

}