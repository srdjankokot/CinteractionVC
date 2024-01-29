import 'package:cinteraction_vc/features/users/provider/users_provider.dart';

import '../../profile/model/user.dart';

class UsersRepository{
  UsersRepository({
    required this.usersProvider
});

  final UsersProvider usersProvider;


  Stream<List<User>?> getUsersStream() {
    return usersProvider.getUserStream();
  }


  Future<void> getListOfUsers() async
  {
    usersProvider.getUsers();
  }


  Future<void> addUser() async
  {
    usersProvider.addUser();
  }

}