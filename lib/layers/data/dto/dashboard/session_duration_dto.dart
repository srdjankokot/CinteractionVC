import 'package:cinteraction_vc/layers/data/dto/dashboard/session_meeting_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/dashboard/session_duration.dart';
import 'package:json_annotation/json_annotation.dart';



@JsonSerializable(explicitToJson: true)
class SessionDurationDto extends SessionDuration {

  SessionDurationDto(
      {required double averageDuration,
      required double averageUsers,
      required List<SessionMeetingDto> meetings})
      : super(
            averageDuration: averageDuration,
            averageUsers: averageUsers,
            meetings: meetings);



  @override
  factory SessionDurationDto.fromJson(Map<String, dynamic> json) {
    var meetings = json["meetings"];

    print('from json $meetings');
    return SessionDurationDto(
      averageDuration: json['avg_duration'] as double,
        averageUsers: json['avg_users'] as double,
        meetings: List<SessionMeetingDto>.from(meetings[0].map((e) => SessionMeetingDto.fromJson(e)) ));
  }


}