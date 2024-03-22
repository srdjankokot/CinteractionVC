import 'package:json_annotation/json_annotation.dart';
part 'data_channel_command.g.dart';

enum DataChannelCmd {
  publish('publish'),
  unPublish('unPublish');

  const DataChannelCmd(this.value);
  final String value;
}


@JsonSerializable()
class DataChannelCommand{

  DataChannelCommand({
    required this.command,
    required this.id,});

  @JsonKey(name: 'cmd')
  DataChannelCmd command;

  @JsonKey(name: 'id')
  String id;


  @override
  factory DataChannelCommand.fromJson(Map<String, dynamic> json) => _$DataChannelCommandFromJson(json);

  Map<String, dynamic> toJson() => _$DataChannelCommandToJson(this);
}