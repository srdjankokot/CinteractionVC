// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imageUrl: json['avatar'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    )
      ..groups = json['groups'] as int?
      ..avgEngagement = json['avgEngagement'] as int?
      ..totalMeetings = json['totalMeetings'] as int?;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'groups': instance.groups,
      'avgEngagement': instance.avgEngagement,
      'totalMeetings': instance.totalMeetings,
      'createdAt': instance.createdAt.toIso8601String(),
      'id': instance.id,
      'email': instance.email,
      'avatar': instance.imageUrl,
    };
