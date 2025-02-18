import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_dto.dart';
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
  late ScrollController _scrollController;
  int currentPage = 1;
  final int paginate = 20;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _updateSelectedChat();
  }

  @override
  void didUpdateWidget(ChatsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.chats!.length != oldWidget.state.chats!.length) {
      _updateSelectedChat();
    }
  }

  void _updateSelectedChat() {
    if (widget.state.chats != null && widget.state.chats!.isNotEmpty) {
      List<ChatDto> sortedChats = List.from(widget.state.chats!)
        ..sort((a, b) {
          bool aIsNewGroup = a.lastMessage == null;
          bool bIsNewGroup = b.lastMessage == null;

          if (aIsNewGroup && !bIsNewGroup) return -1;
          if (!aIsNewGroup && bIsNewGroup) return 1;

          DateTime? aTime = a.lastMessage?.createdAt;
          DateTime? bTime = b.lastMessage?.createdAt;

          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;

          return bTime.compareTo(aTime);
        });

      setState(() {
        selectedChat = sortedChats.first.id;
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

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading) {
      _loadMoreChats();
    }
  }

  Future<void> _loadMoreChats() async {
    if (isLoading || widget.state.pagination?.nextPageUrl == null) {
      debugPrint("⛔ Nema više stranica za učitavanje.");
      return;
    }

    setState(() {
      isLoading = true;
      debugPrint("🚀 Paginacija započeta - isLoading: $isLoading");
    });

    try {
      await context
          .read<ChatCubit>()
          .loadChats(widget.state.pagination!.currentPage + 1, 20);
    } catch (e) {
      debugPrint("⚠️ Greška pri učitavanju poruka: $e");
    }

    setState(() {
      isLoading = false;
      debugPrint("✅ Paginacija završena - isLoading: $isLoading");
    });
  }

  void _deleteChat(int chatId) async {
    await context.read<ChatCubit>().deleteChat(chatId);
    Future.delayed(const Duration(milliseconds: 100), () {
      _updateSelectedChat();
    });
  }

  String formatTime(String? dateTime) {
    if (dateTime == null) return "";
    DateTime parsedTime = DateTime.parse(dateTime);
    return "${parsedTime.hour}:${parsedTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    List<ChatDto> sortedChats = List.from(widget.state.chats!)
      ..sort((a, b) {
        DateTime? aTime = a.lastMessage?.createdAt;
        DateTime? bTime = b.lastMessage?.createdAt;

        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;

        return bTime.compareTo(aTime);
      });
    return widget.state.chats == null || widget.state.chats!.isEmpty
        ? Center(
            child: Text(
              'You still don\'t have any chats',
              style:
                  context.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            itemCount: sortedChats.length +
                ((isLoading && widget.state.pagination?.nextPageUrl != null)
                    ? 1
                    : 0),
            padding: const EdgeInsets.only(bottom: 100),
            itemBuilder: (context, index) {
              if (index < sortedChats.length) {
                var chat = sortedChats[index];
                bool isSelected = chat.id == selectedChat;

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        selectedChat = chat.id;
                      });
                      await context.read<ChatCubit>().getChatDetails(chat.id);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[100] : Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          chat.userImage != null
                              ? UserImage.medium(chat.userImage!)
                              : const UserImage.medium(
                                  "https://ui-avatars.com/api/?name=G+R&color=ffffff&background=f34320"),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chat.name,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  chat.lastMessage?.message?.isNotEmpty == true
                                      ? chat.lastMessage!.message!
                                      : (chat.lastMessage?.filePath != null &&
                                              chat.lastMessage!.filePath!
                                                  .isNotEmpty
                                          ? "File"
                                          : "No messages"),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatTime(
                                chat.lastMessage?.createdAt.toIso8601String()),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black45),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 10),
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.redAccent.shade700),
                              onPressed: () => _showRemoveDialog(
                                  chat.id, context, _deleteChat),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
            },
          );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
