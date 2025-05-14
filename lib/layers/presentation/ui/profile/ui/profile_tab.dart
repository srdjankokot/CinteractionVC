import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cinteraction_vc/core/app/injector.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/extension/context_user.dart';
import 'package:cinteraction_vc/core/navigation/route.dart';
import 'package:cinteraction_vc/core/ui/input/input_field.dart';
import 'package:cinteraction_vc/layers/data/source/local/local_storage.dart';
import 'package:cinteraction_vc/layers/data/source/network/api_impl.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:cinteraction_vc/layers/domain/source/api.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/app/app_state.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/home/home_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _pickAndSendFile(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: kIsWeb);

    if (result == null) {
      debugPrint('User canceled file selection');
      return;
    }

    PlatformFile file = result.files.first;
    Uint8List? fileBytes = file.bytes;

    if (!kIsWeb && fileBytes == null && file.path != null) {
      fileBytes = await File(file.path!).readAsBytes();
    }

    if (fileBytes == null) {
      debugPrint('Error: Bytes not read.');
      return;
    }

    final fileWithBytes = PlatformFile(
      name: file.name,
      size: fileBytes.length,
      bytes: fileBytes,
    );

    try {
      await context.read<AppCubit>().updateUserAfterImageChange(file);
    } catch (e) {
      debugPrint('Failed to update profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final currentUser = state.user;

        final _nameController = TextEditingController();
        final _passwordController = TextEditingController();
        final _confirmPasswordController = TextEditingController();
        final _formKey = GlobalKey<FormState>();

        void submit() async {
          if (!_formKey.currentState!.validate()) {
            return;
          }
          context.closeKeyboard();

          final password = _passwordController.text.trim();
          await context.read<AppCubit>().updateUser(
                name: _nameController.text,
                email: context.getCurrentUser!.email,
                user: context.getCurrentUser!,
                // file: file,
              );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 32),
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 700),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipOval(
                                            child: SizedBox(
                                              width: 120,
                                              height: 120,
                                              child: UserImage.large([
                                                currentUser!.getUserImageDTO()
                                              ]),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 4,
                                            right: 4,
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  Colors.blueAccent,
                                              child: IconButton(
                                                icon: const Icon(Icons.edit,
                                                    size: 16,
                                                    color: Colors.white),
                                                padding: EdgeInsets.zero,
                                                onPressed: () =>
                                                    _pickAndSendFile(context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 24),

                                      TextField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: currentUser.name,
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          prefixIcon: const Icon(Icons.person),
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Email
                                      // TextField(
                                      //   controller: TextEditingController(
                                      //       text: user.email),
                                      //   decoration: InputDecoration(
                                      //     labelText: 'Email',
                                      //     filled: true,
                                      //     fillColor: Colors.grey[100],
                                      //     border: OutlineInputBorder(
                                      //       borderRadius:
                                      //           BorderRadius.circular(12),
                                      //     ),
                                      //     prefixIcon: const Icon(Icons.email),
                                      //   ),
                                      // ),

                                      const SizedBox(height: 24),

                                      // Password
                                      InputField.password(
                                        label: 'Enter your password',
                                        controller: _passwordController,
                                        textInputAction: TextInputAction.next,
                                        onFieldSubmitted: null,
                                        // textInputAction: state.isSignUp
                                        //     ? TextInputAction.next
                                        //     : TextInputAction.done,
                                        // onFieldSubmitted:  (){}
                                      ),

                                      const SizedBox(height: 16),

                                      // Confirm Password
                                      InputField(
                                        label: 'Confirm password',
                                        controller: _confirmPasswordController,
                                        textInputAction: TextInputAction.done,
                                        //  onFieldSubmitted: (_) => submit(),
                                        keyboardType:
                                            TextInputType.visiblePassword,
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
                                        validator: (confirmPassword) {
                                          if (confirmPassword == null ||
                                              confirmPassword.isEmpty) {
                                            return 'Required';
                                          }

                                          if (_passwordController.text !=
                                              confirmPassword) {
                                            return 'Password doesn\'t match';
                                          }
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                submit();
                                              },
                                              icon: const Icon(Icons.save),
                                              label: const Text('Save'),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () {},
                                              icon: const Icon(Icons.cancel),
                                              label: const Text('Cancel'),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 300,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.logOut();
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text('Log out'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
