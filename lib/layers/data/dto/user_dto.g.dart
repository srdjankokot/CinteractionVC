// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      imageUrl: json['profile_photo_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    )
      ..emailVerifiedAt = json['email_verified_at'] == null
          ? null
          : DateTime.parse(json['email_verified_at'] as String)
      ..groups = json['groups'] as int?
      ..avgEngagement = json['avgEngagement'] as int?
      ..totalMeetings = json['totalMeetings'] as int?;

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profile_photo_url': instance.imageUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
      'groups': instance.groups,
      'avgEngagement': instance.avgEngagement,
      'totalMeetings': instance.totalMeetings,
    };
