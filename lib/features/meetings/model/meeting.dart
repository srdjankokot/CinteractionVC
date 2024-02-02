
import '../../profile/model/user.dart';

class Meeting {
  Meeting({
    required this.id,
    this.passcode,
    required this.name,
    required this.organizer,
    required this.users,
    required this.avgEngagement,
    required this.recorded,
    required this.start,
    required this.end,

  });


  final String id;
  final String? passcode;
  final String name;
  final User organizer;
  final List<User> users;
  final int avgEngagement;
  final bool recorded;
  final DateTime start;
  final DateTime end;

}