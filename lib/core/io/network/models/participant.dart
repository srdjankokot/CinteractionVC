import 'package:json_annotation/json_annotation.dart';

import '../../../../layers/domain/entities/chat_message.dart';

part 'participant.g.dart';

@JsonSerializable()
class Participant {
  Participant({
    required this.id,
    required this.display,
    this.publisher = false,
    this.talking = false,
  });

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'display')
  String display;

  @JsonKey(name: 'publisher')
  bool publisher;

  @JsonKey(name: 'talking')
  bool talking;

  List<ChatMessage> messages = [];

  bool haveUnreadMessages = false;

  @override
  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}
