import 'package:json_annotation/json_annotation.dart';

part 'participant.g.dart';


@JsonSerializable()
class Participant{

  Participant({
    required this.id,
    required this.display,
    this.publisher = false,
    this.talking = false,});

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'display')
  String display;

  @JsonKey(name: 'publisher')
  bool publisher;

  @JsonKey(name: 'talking')
  bool talking;


  @override
  factory Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);

}