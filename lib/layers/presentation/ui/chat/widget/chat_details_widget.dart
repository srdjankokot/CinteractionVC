import 'dart:io';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatDetailsWidget extends StatefulWidget {
  final ChatState chatState;

  const ChatDetailsWidget(this.chatState, {Key? key}) : super(key: key);

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

  ChatParticipantDto? getUserById(int senderId) {
    final matchingParticipants = widget.chatState.chatDetails!.chatParticipants
        .where((participant) => participant.id == senderId);
    return matchingParticipants.isNotEmpty ? matchingParticipants.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final sortedMessages = List.of(widget.chatState.chatDetails!.messages)
      ..sort((a, b) {
        final DateTime timeA = DateTime.parse(a.createdAt);
        final DateTime timeB = DateTime.parse(b.createdAt);
        return timeB.compareTo(timeA);
      });

    return Column(
      children: [
        const SizedBox(height: 40),
        Expanded(
          child: sortedMessages.isEmpty
              ? const Center(
                  child: Text(
                    "No messages available.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: sortedMessages.length,
                  itemBuilder: (context, index) {
                    final message = sortedMessages[index];
                    final isSentByUser = message.senderId ==
                        widget.chatState.chatDetails!.authUser.id;

                    final user = getUserById(message.senderId);

                    // Provera da li je ovo prva poruka ili se senderId promenio
                    final bool shouldShowImage =
                        index == sortedMessages.length - 1 ||
                            (index < sortedMessages.length - 1 &&
                                sortedMessages[index + 1].senderId !=
                                    message.senderId);

                    return Align(
                      alignment: isSentByUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 50),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            if (!isSentByUser &&
                                user != null &&
                                shouldShowImage)
                              Positioned(
                                top: -10,
                                left: -50,
                                child: UserImage.medium(
                                  "https://ui-avatars.com/api/?name=${user.name}&color=ffffff&background=f34320",
                                ),
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isSentByUser && user != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          user.name.split(" ").first,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          DateFormat('hh:mm a').format(
                                              DateTime.parse(
                                                  message.createdAt)),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 2),
                                Align(
                                  alignment: isSentByUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSentByUser
                                          ? Colors.blue[100]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                            isSentByUser ? 12 : 0),
                                        topRight: Radius.circular(
                                            isSentByUser ? 0 : 12),
                                        bottomLeft: const Radius.circular(12),
                                        bottomRight: const Radius.circular(12),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75,
                                    ),
                                    child: Text(
                                      message.message ?? '',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
