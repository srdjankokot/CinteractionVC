import 'package:cinteraction_vc/layers/domain/entities/participant.dart';
import 'package:json_annotation/json_annotation.dart';

part 'participant_dto.g.dart';


@JsonSerializable()
class ParticipantDto extends Participant{

  ParticipantDto({required super.id, required super.display});

  @override
  factory ParticipantDto.fromJson(Map<String, dynamic> json) => _$ParticipantDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantDtoToJson(this);

}