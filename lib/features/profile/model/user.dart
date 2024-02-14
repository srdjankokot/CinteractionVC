import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
   User( {
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.createdAt,
  });


  final String name;

  int? groups = Random().nextInt(10);
  int? avgEngagement = Random().nextInt(100);
  int? totalMeetings = Random().nextInt(50);

  final bool onboarded =  Random().nextInt(2) == 1;
  late final bool checked  =  Random().nextInt(2) == 1;
  final DateTime createdAt;


   factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

   Map<String, dynamic> toJson() => _$UserToJson(this);

   String id;
   String email;

   @JsonKey(name: 'avatar')
   String imageUrl;


}
