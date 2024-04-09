import 'package:cinteraction_vc/layers/presentation/ui/users/ui/widget/user_list_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../../core/ui/widget/loading_overlay.dart';
import '../../../../domain/entities/user.dart';
import '../../../cubit/users/users_cubit.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.groupId});

  final String groupId;

  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {
  late List<User>? userList = [];



  @override
  void initState(){
    super.initState();

    print(widget.groupId);

    if(widget.groupId == '') {
      context.read<UsersCubit>().loadUsers();
    } else {
      context.read<UsersCubit>().loadUsersOfGroup(widget.groupId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UsersCubit, UsersState>(
        builder: (context, state) {
          final Widget body;
          body = Column(
              children: [
                UserListLayout(users: userList!),
              ],
          );

          return LoadingOverlay(
              loading: state is UsersIsLoading,
              child: SizedBox(
                height: double.maxFinite,
                width: double.maxFinite,
                  child: body,
              ));
        },
        listener: _onUsersState);
  }

  void _onUsersState(BuildContext context, UsersState state) {
    if (state is UsersLoaded) {
      setState(() {
        userList = state.users;
      });
    }
  }
}
