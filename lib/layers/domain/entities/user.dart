import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.createdAt,
    this.emailVerifiedAt,
  });

  int id;
  String name;
  String email;

  @JsonKey(name: 'profile_photo_url')
  String imageUrl;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'email_verified_at')
  DateTime? emailVerifiedAt;

  int? groups = Random().nextInt(10);
  int? avgEngagement = Random().nextInt(100);
  int? totalMeetings = Random().nextInt(50);

  final bool onboarded =  Random().nextInt(2) == 1;
  late final bool checked  =  Random().nextInt(2) == 1;


}