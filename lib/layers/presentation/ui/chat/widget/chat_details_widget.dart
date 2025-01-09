import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDetailsWidget extends StatefulWidget {
  final ChatDetailsDto chatDetails;

  const ChatDetailsWidget(this.chatDetails, {Key? key}) : super(key: key);

  @override
  _ChatDetailsWidgetState createState() => _ChatDetailsWidgetState();
}

class _ChatDetailsWidgetState extends State<ChatDetailsWidget> {
  final ScrollController _scrollController = ScrollController();

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
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSentByUser ? Colors.red[300] : Colors.red[100],
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
                          color: isSentByUser ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd.MM.yyyy HH:mm')
                            .format(DateTime.parse(message.createdAt)),
                        style: TextStyle(
                          color: isSentByUser ? Colors.white70 : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
