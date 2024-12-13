import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../chat/link_text.dart';
import '../../profile/ui/widget/user_image.dart';

class ChatDetailsWidget extends StatelessWidget {
  final ChatDetailsDto chatDetails;

  const ChatDetailsWidget(this.chatDetails, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: chatDetails.messages.length,
            itemBuilder: (context, index) {
              final message = chatDetails.messages?[index];
              if (message == null) return const SizedBox.shrink();

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    message.senderId == chatDetails.authUser.id
                        ? chatDetails.authUser.image
                        : chatDetails.chatParticipants
                            .firstWhere((participant) =>
                                participant.id == message.senderId)
                            .image,
                  ),
                ),
                title: Text(
                  message.message ?? "File Sent",
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  message.createdAt,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
