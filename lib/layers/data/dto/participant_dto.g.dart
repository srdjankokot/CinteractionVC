// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParticipantDto _$ParticipantDtoFromJson(Map<String, dynamic> json) =>
    ParticipantDto(
      id: json['id'] as int,
      display: json['display'] as String,
    )
      ..publisher = json['publisher'] as bool
      ..talking = json['talking'] as bool;

Map<String, dynamic> _$ParticipantDtoToJson(ParticipantDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display': instance.display,
      'publisher': instance.publisher,
      'talking': instance.talking,
    };
