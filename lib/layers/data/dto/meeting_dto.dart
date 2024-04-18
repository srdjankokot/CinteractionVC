import 'package:cinteraction_vc/layers/domain/entities/meeting.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class MeetingDto extends Meeting {
  MeetingDto(
      {required super.callId,
      required super.organizerId,
      required super.organizer,
      required super.averageEngagement,
      required super.totalNumberOfUsers,
      required super.recorded,
      required super.meetingStart,
      required super.meetingEnd});

  @override
  factory MeetingDto.fromJson(Map<String, dynamic> json) =>
      _$MeetingDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingDtoToJson(this);
}
