import 'dart:math';

class User {
   User( {
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String imageUrl;

  int? groups = Random().nextInt(10);
  int? avgEngagement = Random().nextInt(100);
  int? totalMeetings = Random().nextInt(50);

  final bool onboarded =  Random().nextInt(2) == 1;
  late final bool checked  =  Random().nextInt(2) == 1;
  final DateTime createdAt;
}
