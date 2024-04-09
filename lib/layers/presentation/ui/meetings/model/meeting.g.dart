// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meeting _$MeetingFromJson(Map<String, dynamic> json) => Meeting(
      id: json['id'] as int,
      name: json['event_name'] as String,
      passcode: json['passcode'] as String?,
      organizer: UserDto.fromJson(json['organizer'] as Map<String, dynamic>),
      users: (json['users'] as List<dynamic>)
          .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      avgEngagement: json['average_engagement'] as int,
      recorded: json['recorded'] as bool,
      start: DateTime.parse(json['meeting_start'] as String),
      end: DateTime.parse(json['meeting_end'] as String),
    );

Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
      'recorded': instance.recorded,
      'id': instance.id,
      'event_name': instance.name,
      'passcode': instance.passcode,
      'organizer': instance.organizer,
      'average_engagement': instance.avgEngagement,
      'users': instance.users,
      'meeting_start': instance.start.toIso8601String(),
      'meeting_end': instance.end.toIso8601String(),
    };
