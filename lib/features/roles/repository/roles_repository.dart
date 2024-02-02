
import 'package:cinteraction_vc/features/groups/model/group.dart';

import '../../profile/model/user.dart';
import '../model/role.dart';
import '../provider/roles_provider.dart';

class RolesRepository{
  RolesRepository({
    required this.rolesProvider
});

  final RolesProvider rolesProvider;


  Stream<List<Role>> getRolesStream() {
    return rolesProvider.getRoleStream();
  }


  Future<void> getListOfRoles() async
  {
    rolesProvider.getRoles();
  }


  Future<void> addRole() async
  {
    rolesProvider.addRole();
  }

}