import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../cubit/chat/chat_cubit.dart';
import '../../../cubit/chat/chat_state.dart';
import '../../profile/ui/widget/user_image.dart';

class ChatsListView extends StatefulWidget {
  final ChatState state;

  const ChatsListView({Key? key, required this.state}) : super(key: key);

  @override
  State<ChatsListView> createState() => _ChatsListViewState();
}

class _ChatsListViewState extends State<ChatsListView> {
  int? selectedChat;
  @override
  void initState() {
    super.initState();
    if (widget.state.chats != null && widget.state.chats!.isNotEmpty) {
      selectedChat = widget.state.chats!.first.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // context.read<ChatCubit>().getChatDetails(widget.state.chats![0].id);
        print('ChatsStata: ${widget.state.chats}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.state.chats == null || widget.state.chats!.isEmpty
        ? Center(
            child: Text(
              'You still don\'t have any chats',
              style:
                  context.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: widget.state.chats?.length ?? 0,
            itemBuilder: (context, index) {
              var chat = widget.state.chats![
                  index]; // Ovdje više ne postoji rizik od greške jer je prethodno provereno

              return GestureDetector(
                onTap: () async {
                  setState(() {
                    selectedChat = chat.id;
                  });
                  await context.read<ChatCubit>().getChatDetails(chat.id);
                  print('StateIsLoading: ${widget.state.isLoading}');
                },
                child: Container(
                  color:
                      chat.id == selectedChat ? Colors.blue[100] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Stack(
                          children: [
                            UserImage.medium(widget.state.chats![index].name),
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
