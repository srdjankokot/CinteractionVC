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
    List<String>? deviceId,
  }) : deviceId = deviceId ?? [];

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'display')
  String display;

  @JsonKey(name: 'publisher')
  bool publisher;

  @JsonKey(name: 'talking')
  bool talking;

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<String> deviceId;

  List<ChatMessage> messages = [];

  bool haveUnreadMessages = false;

  bool get isOnline => deviceId.isNotEmpty;

  @override
  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantToJson(this);
}
