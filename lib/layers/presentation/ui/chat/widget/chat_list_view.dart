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
    _updateSelectedChat();
  }

  @override
  void didUpdateWidget(ChatsListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state.chats != oldWidget.state.chats) {
      _updateSelectedChat();
    }
  }

  void _updateSelectedChat() {
    if (widget.state.chats != null && widget.state.chats!.isNotEmpty) {
      setState(() {
        selectedChat = widget.state.chats!.first.id;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatCubit>().getChatDetails(selectedChat);
      });
    } else {
      setState(() {
        selectedChat = null;
      });
    }
  }

  void _deleteChat(int chatId) async {
    await context.read<ChatCubit>().deleteChat(chatId);
    Future.delayed(Duration(milliseconds: 100), () {
      _updateSelectedChat();
    });
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
              var chat = widget.state.chats![index];
              bool isSelected = chat.id == selectedChat;

              return GestureDetector(
                onTap: () async {
                  setState(() {
                    selectedChat = chat.id;
                  });
                  await context.read<ChatCubit>().getChatDetails(chat.id);
                },
                child: Container(
                  color: isSelected ? Colors.blue[100] : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          chat.userImage != null
                              ? UserImage.medium(chat.userImage!)
                              : const UserImage.medium(
                                  "https:\/\/ui-avatars.com\/api\/?name=G+R&color=ffffff&background=f34320"),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          chat.name,
                          style: context.textTheme.titleMedium,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showRemoveDialog(chat.id, context, _deleteChat),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }
}

void _showRemoveDialog(int chatId, context, Function(int) deleteChat) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Remove Conversation"),
        content: const Text(
          "Are you sure you want to delete this conversation?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              deleteChat(chatId);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}
