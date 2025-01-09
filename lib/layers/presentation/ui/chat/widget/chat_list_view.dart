import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../cubit/chat/chat_cubit.dart';
import '../../../cubit/chat/chat_state.dart';
import '../../profile/ui/widget/user_image.dart';

class ChatsListView extends StatelessWidget {
  final ChatState state;

  const ChatsListView({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.chats?.length ?? 0,
      itemBuilder: (context, index) {
        var chat = state.chats![index];

        return GestureDetector(
          onTap: () async {
            await context.read<ChatCubit>().getChatDetails(chat.id);
          },
          child: Container(
            color: chat.id == state.chatDetails?.chatId
                ? ColorConstants.kPrimaryColor.withOpacity(0.2)
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      UserImage.medium(chat.name),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.name,
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.lastMessage?.message ?? "",
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
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
