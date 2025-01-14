import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/chat/chat_cubit.dart';
import '../../../cubit/chat/chat_state.dart';
import '../../profile/ui/widget/user_image.dart';

class UsersListView extends StatefulWidget {
  final ChatState state;

  const UsersListView({Key? key, required this.state}) : super(key: key);

  @override
  State<UsersListView> createState() => _UsersListViewState();
}

class _UsersListViewState extends State<UsersListView> {
  int? selectedUserId;

  @override
  void initState() {
    super.initState();
    if (widget.state.users != null && widget.state.users!.isNotEmpty) {
      selectedUserId =
          int.parse(widget.state.users!.first.id.replaceFirst('hash_', ''));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatCubit>().getChatDetailsByParticipiant(selectedUserId!);
        context.read<ChatCubit>().setCurrentParticipant(widget.state.users![0]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.state.users?.length ?? 0,
      itemBuilder: (context, index) {
        var user = widget.state.users![index];
        int userId = int.parse(user.id.replaceFirst('hash_', ''));

        return GestureDetector(
          onTap: () async {
            setState(() {
              selectedUserId = userId;
            });
            await context
                .read<ChatCubit>()
                .getChatDetailsByParticipiant(userId);
            await context.read<ChatCubit>().setCurrentParticipant(user);
          },
          child: Container(
            color: userId == selectedUserId ? Colors.blue[100] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      UserImage.medium(user.imageUrl),
                      Visibility(
                        visible: user.online,
                        child: Positioned(
                          bottom: 2,
                          right: 4,
                          child: ClipOval(
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
