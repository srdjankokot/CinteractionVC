// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Participant _$ParticipantFromJson(Map<String, dynamic> json) => Participant(
      id: json['id'] as int,
      display: json['display'] as String,
      // publisher: json['publisher'] as bool,
      publisher : json.containsKey('publisher')?  json['publisher'] as bool : false,
      talking: json.containsKey('talking')?  json['talking'] as bool : false,

    );

Map<String, dynamic> _$ParticipantToJson(Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display': instance.display,
      'publisher': instance.publisher,
      'talking': instance.talking,
    };
