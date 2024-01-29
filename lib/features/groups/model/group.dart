import '../../profile/model/user.dart';

class Group {

  Group({
    required this.id,
    required this.name, required List<User> userList,
  });

  final String id;
  final String name;
  List<User> userList = [];

}