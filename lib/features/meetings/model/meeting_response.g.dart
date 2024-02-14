// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingResponse _$MeetingResponseFromJson(Map<String, dynamic> json) =>
    MeetingResponse(
      pastMeetings: (json['pastMeetings'] as List<dynamic>)
          .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
          .toList(),
      scheduleMeetings: (json['scheduleMeetings'] as List<dynamic>)
          .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MeetingResponseToJson(MeetingResponse instance) =>
    <String, dynamic>{
      'pastMeetings': instance.pastMeetings,
      'scheduleMeetings': instance.scheduleMeetings,
    };
