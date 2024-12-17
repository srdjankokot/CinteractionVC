import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDetailsWidget extends StatelessWidget {
  final ChatDetailsDto chatDetails;

  const ChatDetailsWidget(this.chatDetails, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sortiranje poruka po datumu (od najstarije ka najnovijoj)
    final sortedMessages = List.of(chatDetails.messages)
      ..sort((a, b) =>
          DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));

    return Column(
      children: [
        const SizedBox(height: 40),
        Expanded(
          child: ListView.builder(
            itemCount: sortedMessages.length,
            itemBuilder: (context, index) {
              final message = sortedMessages[index];
              final isSentByUser = message.senderId == chatDetails.authUser.id;

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
}
