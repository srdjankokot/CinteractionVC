// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
      id: json['id'] as String,
      display: json['display'] as String,
      publisher: json['publisher'] as bool? ?? false,
      talking: json['talking'] as bool? ?? false,
    );

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display': instance.display,
      'publisher': instance.publisher,
      'talking': instance.talking,
    };
