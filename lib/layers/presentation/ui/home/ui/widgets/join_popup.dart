import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JoinPopup extends StatelessWidget {
  const JoinPopup({super.key});

  @override
  Widget build(BuildContext context) {

    TextEditingController _textFieldController = TextEditingController();

        return AlertDialog(
          title: const Text('Enter room ID'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "Room ID"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Join'),
              onPressed: () {
                // print(_textFieldController.text);
                Navigator.pop(context);
                context.pushNamed('meeting',
                    pathParameters: {
                      'roomId': _textFieldController.text,
                    },
                    extra: context.getCurrentUser?.name);

                // context.go("${AppRoute.meeting.path}/${_textFieldController.text}");
              },
            ),
          ],
    );
  }

}