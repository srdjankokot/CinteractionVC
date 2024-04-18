import 'package:json_annotation/json_annotation.dart';

import 'meeting_dto.dart';

part 'past_meetings_response_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class PastMeetingResponseDto{

  PastMeetingResponseDto({required meetingList});

  @JsonKey(name: 'data')
  List<MeetingDto>? meetingList;


  @override
  factory PastMeetingResponseDto.fromJson(Map<String, dynamic> json) => _$PastMeetingResponseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PastMeetingResponseDtoToJson(this);
}