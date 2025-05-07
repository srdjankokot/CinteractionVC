import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import '../../data/dto/chat/chat_detail_dto.dart';
import '../../presentation/ui/profile/ui/widget/user_image.dart';

class User {
  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.imageUrl,
      this.createdAt,
      this.emailVerifiedAt,
      this.online = false});

  String id;
  String name;
  String email;
  bool online;

  @JsonKey(name: 'profile_photo_url')
  String imageUrl;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'email_verified_at')
  DateTime? emailVerifiedAt;

  int? groups = Random().nextInt(10);
  int? avgEngagement = Random().nextInt(100);
  int? totalMeetings = Random().nextInt(50);

  final bool onboarded = Random().nextInt(2) == 1;
  late final bool checked = Random().nextInt(2) == 1;




  UserImageDto getUserImageDTO()
  {
    return UserImageDto(
      id: int.parse(id),
        name: name,
        imageUrl: imageUrl
    );
  }
}
