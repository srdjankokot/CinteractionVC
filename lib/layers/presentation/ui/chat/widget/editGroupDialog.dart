import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:flutter/material.dart';

import '../../profile/ui/widget/user_image.dart';

class EditGroupDialog extends StatelessWidget {
  final ChatState state;

  const EditGroupDialog({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserImage.medium(
                "https:\/\/ui-avatars.com\/api\/?name=G+R&color=ffffff&background=f34320"),
            const SizedBox(height: 16.0),

            Text(
              state.chatDetails?.chatName ?? "Group Name",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            // Participants Info
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${state.chatDetails?.chatParticipants.length} participants",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Participants List
            Container(
              height: 400,
              width: 500,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.chatDetails?.chatParticipants.length,
                itemBuilder: (context, index) {
                  final participant =
                      state.chatDetails?.chatParticipants[index];
                  return HoverParticipantTile(
                    participant: participant,
                    onRemove: () {
                      _showRemoveDialog(context, participant?.name ?? "",
                          state.chatDetails!.chatId!, participant!.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            // Add your save logic here
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  void _showRemoveDialog(
      BuildContext context, String participantName, int chatId, int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove Participant"),
          content: Text(
            "Remove $participantName from this conversation?",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Zatvara mini pop-up
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                await getIt
                    .get<ChatCubit>()
                    .chatUseCases
                    .removeUserFromGroup(chatId, userId);
                Navigator.of(context).pop();
              },
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );
  }
}

class HoverParticipantTile extends StatefulWidget {
  final dynamic participant;
  final VoidCallback onRemove;

  const HoverParticipantTile({
    super.key,
    required this.participant,
    required this.onRemove,
  });

  @override
  State<HoverParticipantTile> createState() => _HoverParticipantTileState();
}

class _HoverParticipantTileState extends State<HoverParticipantTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            widget.participant?.image ??
                "https://ui-avatars.com/api/?name=${widget.participant?.name}+${widget.participant?.name}&color=ffffff&background=007bff",
          ),
        ),
        title: Text(
          "${widget.participant?.name}",
          style: const TextStyle(fontSize: 16),
        ),
        trailing: _isHovered
            ? TextButton(
                onPressed: widget.onRemove,
                child: const Text(
                  "Remove",
                  style: TextStyle(color: Colors.red),
                ),
              )
            : null,
      ),
    );
  }
}
