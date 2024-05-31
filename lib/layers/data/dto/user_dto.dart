import '../../domain/entities/user.dart';

class UserDto extends User {
  UserDto(
      {required super.id,
      required super.name,
      required super.email,
      required super.imageUrl,
      required super.createdAt});


  factory UserDto.fromJson(Map<String, dynamic> json) =>
      UserDto(
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


  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'profile_photo_url': imageUrl,
    'created_at': createdAt.toIso8601String(),
    'email_verified_at': emailVerifiedAt?.toIso8601String(),
    'groups': groups,
    'avgEngagement': avgEngagement,
    'totalMeetings': totalMeetings,
  };
}
