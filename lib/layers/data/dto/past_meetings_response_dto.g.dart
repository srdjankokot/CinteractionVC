// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'past_meetings_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PastMeetingResponseDto _$PastMeetingResponseDtoFromJson(
        Map<String, dynamic> json) =>
    PastMeetingResponseDto(
      meetingList: json['data'],
    );

Map<String, dynamic> _$PastMeetingResponseDtoToJson(
        PastMeetingResponseDto instance) =>
    <String, dynamic>{
      'data': instance.meetingList?.map((e) => e.toJson()).toList(),
    };
