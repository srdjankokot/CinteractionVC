// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingDto _$MeetingDtoFromJson(Map<String, dynamic> json) => MeetingDto(
      callId: json['call_id'] as int,
      organizerId: json['organizer_id'] as int,
      organizer: json['organizer'] as String,
      averageEngagement: (json['average_engagement'] as num).toDouble(),
      totalNumberOfUsers: json['total_number_of_users'] as int,
      recorded: json['recorded'] as bool,
      meetingStart: DateTime.parse(json['meeting_start'] as String),
      meetingEnd: json['meeting_end'] == null
          ? null
          : DateTime.parse(json['meeting_end'] as String),
    );

Map<String, dynamic> _$MeetingDtoToJson(MeetingDto instance) =>
    <String, dynamic>{
      'call_id': instance.callId,
      'organizer_id': instance.organizerId,
      'organizer': instance.organizer,
      'average_engagement': instance.averageEngagement,
      'total_number_of_users': instance.totalNumberOfUsers,
      'recorded': instance.recorded,
      'meeting_start': instance.meetingStart.toIso8601String(),
      'meeting_end': instance.meetingEnd?.toIso8601String(),
    };
