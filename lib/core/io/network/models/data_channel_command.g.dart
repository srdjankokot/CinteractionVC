// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_channel_command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataChannelCommand _$DataChannelCommandFromJson(Map<String, dynamic> json) =>
    DataChannelCommand(
      command: $enumDecode(_$DataChannelCmdEnumMap, json['cmd']),
      id: json['id'] as String,
    );

Map<String, dynamic> _$DataChannelCommandToJson(DataChannelCommand instance) =>
    <String, dynamic>{
      'cmd': _$DataChannelCmdEnumMap[instance.command]!,
      'id': instance.id,
    };

const _$DataChannelCmdEnumMap = {
  DataChannelCmd.publish: 'publish',
  DataChannelCmd.unPublish: 'unPublish',
};
