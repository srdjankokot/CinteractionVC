import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateGroupDialog extends StatelessWidget {
  final ChatState state; // Lista korisnika za prikaz
  const CreateGroupDialog({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    TextEditingController groupNameController = TextEditingController();
    ValueNotifier<List<String>> selectedUsers = ValueNotifier([]);

    void _showValidationError(String message) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text("Create New Group"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text("Add Users:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Container(
              height: 400,
              width: 500,
              child: ValueListenableBuilder<List<String>>(
                valueListenable: selectedUsers,
                builder: (context, selectedList, child) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.users?.length ?? 0,
                    itemBuilder: (context, index) {
                      var user = state.users![index];
                      return CheckboxListTile(
                        title: Text(user.name),
                        value: selectedList.contains(user.name),
                        onChanged: (isChecked) {
                          if (isChecked ?? false) {
                            selectedUsers.value.add(user.name);
                          } else {
                            selectedUsers.value.remove(user.name);
                          }
                          selectedUsers.notifyListeners();
                        },
                      );
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
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (groupNameController.text.isEmpty) {
              _showValidationError("Please enter a group name.");
              return;
            }
            if (selectedUsers.value.isEmpty) {
              _showValidationError("Please select at least one user.");
              return;
            }

            Navigator.of(context).pop({
              'groupName': groupNameController.text,
              'selectedUsers': selectedUsers.value,
            });
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
