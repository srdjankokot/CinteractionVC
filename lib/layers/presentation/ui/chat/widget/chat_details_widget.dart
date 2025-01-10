import 'dart:io';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatDetailsWidget extends StatefulWidget {
  final ChatDetailsDto chatDetails;

  const ChatDetailsWidget(this.chatDetails, {Key? key}) : super(key: key);

  @override
  _ChatDetailsWidgetState createState() => _ChatDetailsWidgetState();
}

class _ChatDetailsWidgetState extends State<ChatDetailsWidget> {
  final ScrollController _scrollController = ScrollController();
  int? _hoveredMessageId;
  @override
  void didUpdateWidget(covariant ChatDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedMessages = List.of(widget.chatDetails.messages)
      ..sort((a, b) =>
          DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

    return Column(
      children: [
        const SizedBox(height: 40),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: sortedMessages.length,
            itemBuilder: (context, index) {
              final message = sortedMessages[index];
              final isSentByUser =
                  message.senderId == widget.chatDetails.authUser.id;

              return Align(
                alignment:
                    isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredMessageId =
                      message.id), // ID poruke na kojoj je hover
                  onExit: (_) => setState(() => _hoveredMessageId = null),
                  child: GestureDetector(
                    onLongPress: () async {
                      if (isSentByUser &&
                          (Platform.isIOS || Platform.isAndroid)) {
                        // Mobilni uređaji
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text("Edit Message"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // context.read<ChatCubit>().editChatMessage(message.id!);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: const Text("Delete Message"),
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.read<ChatCubit>().deleteChatMessage(
                                        message.id!, message.chatId);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSentByUser
                                ? Colors.blue[900]
                                : Colors.blue[100],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isSentByUser ? 12 : 0),
                              topRight: Radius.circular(isSentByUser ? 0 : 12),
                              bottomLeft: const Radius.circular(12),
                              bottomRight: const Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.message ?? "File Sent",
                                style: TextStyle(
                                  color: isSentByUser
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd.MM.yyyy HH:mm')
                                    .format(DateTime.parse(message.createdAt)),
                                style: TextStyle(
                                  color: isSentByUser
                                      ? Colors.white70
                                      : Colors.grey,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSentByUser &&
                            (kIsWeb || Platform.isWindows) &&
                            _hoveredMessageId == message.id)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                showMenu(
                                  context: context,
                                  position:
                                      const RelativeRect.fromLTRB(100, 0, 0, 0),
                                  items: [
                                    const PopupMenuItem(
                                      value: "edit",
                                      child: const Text("Edit Message"),
                                    ),
                                    const PopupMenuItem(
                                      value: "delete",
                                      child: const Text("Delete Message"),
                                    ),
                                  ],
                                ).then((value) {
                                  if (value == "edit") {
                                    context.read<ChatCubit>().editChatMessage(
                                        message.id!,
                                        'Test edit',
                                        message.chatId);
                                  } else if (value == "delete") {
                                    context.read<ChatCubit>().deleteChatMessage(
                                        message.id!, message.chatId);
                                  }
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
