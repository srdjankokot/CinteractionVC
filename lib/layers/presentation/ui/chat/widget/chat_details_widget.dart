import 'dart:convert';
import 'dart:io';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/core/util/text_file.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/pdf_viewer_screen.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;

class ChatDetailsWidget extends StatefulWidget {
  final ChatState chatState;

  const ChatDetailsWidget(this.chatState, {Key? key}) : super(key: key);

  @override
  _ChatDetailsWidgetState createState() => _ChatDetailsWidgetState();
}

class _ChatDetailsWidgetState extends State<ChatDetailsWidget> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _hoverStates = {};
  bool _isLoadingMore = false;

  @override
  void didUpdateWidget(covariant ChatDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // _scrollToBottom();
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

  void _loadMoreMessages() async {
    final nextPageLink = widget.chatState.chatDetails!.messages.links?['next'];
    if (_isLoadingMore || nextPageLink == null) {
      return;
    }
    setState(() {
      _isLoadingMore = true;
    });

    await context.read<ChatCubit>().getChatDetails(
        widget.chatState.chatDetails!.chatId,
        widget.chatState.chatDetails!.messages.meta?['current_page'] + 1);

    setState(() {
      _isLoadingMore = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !_isLoadingMore) {
      _loadMoreMessages();
    }
  }

  ChatParticipantDto? getUserById(int senderId) {
    final matchingParticipants = widget.chatState.chatDetails!.chatParticipants
        .where((participant) => participant.id == senderId);
    return matchingParticipants.isNotEmpty ? matchingParticipants.first : null;
  }

  bool _isImage(String url) {
    return url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.gif');
  }

  bool _isPdf(String url) {
    print("Checking if PDF: $url");
    return url.toLowerCase().endsWith('.pdf');
  }

  bool _isTextFile(String url) {
    return url.toLowerCase().endsWith('.txt') ||
        url.toLowerCase().endsWith('.csv') ||
        url.toLowerCase().endsWith('.json');
  }

  String _getFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              Image.network(imagePath, fit: BoxFit.cover),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.red),
                  onPressed: () async {
                    await _downloadImage(imagePath);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadImage(String url) async {
    try {
      Response response = await Dio()
          .get(url, options: Options(responseType: ResponseType.bytes));

      if (response.statusCode == 200) {
        final blob = html.Blob([response.data]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'downloaded_image.jpg';

        anchor.click();
        html.Url.revokeObjectUrl(url);

        print("Image downloaded successfully!");
      } else {
        throw Exception(
            "Error while downloading image: ${response.statusCode}");
      }
    } catch (e) {
      print("Error while downloading: $e");
    }
  }

  String? _editingMessageId;
  String _editingText = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final chatDetails = state.chatDetails;
        final messages = chatDetails?.messages.messages ?? [];
        final sortedMessages = List.of(messages)
          ..sort((a, b) {
            final DateTime timeA = DateTime.parse(a.createdAt);
            final DateTime timeB = DateTime.parse(b.createdAt);
            return timeB.compareTo(timeA);
          });

        if (state.isInitialLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

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
                        final isSentByUser =
                            message.senderId == chatDetails?.authUser.id;
                        final user = getUserById(message.senderId);
                        final bool shouldShowImage =
                            index == sortedMessages.length - 1 ||
                                (index < sortedMessages.length - 1 &&
                                    sortedMessages[index + 1].senderId !=
                                        message.senderId);

                        return MouseRegion(
                          onEnter: (_) =>
                              setState(() => _hoverStates[index] = true),
                          onExit: (_) =>
                              setState(() => _hoverStates[index] = false),
                          child: Align(
                            alignment: isSentByUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                if (_hoverStates[index] == true && isSentByUser)
                                  Positioned(
                                    top: 0,
                                    right: isSentByUser ? 5 : null,
                                    left: isSentByUser ? null : 0,
                                    child: GestureDetector(
                                      onTapDown: (TapDownDetails details) {
                                        final RenderBox overlay =
                                            Overlay.of(context)
                                                    .context
                                                    .findRenderObject()
                                                as RenderBox;
                                        showMenu(
                                          context: context,
                                          position: RelativeRect.fromRect(
                                            details.globalPosition &
                                                const Size(40, 40),
                                            Offset.zero & overlay.size,
                                          ),
                                          items: message.files != null &&
                                                  message.files!.isNotEmpty
                                              ? [
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Delete'),
                                                  ),
                                                ]
                                              : [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text('Edit'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'copy',
                                                    child: Text('Copy'),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                        ).then((value) {
                                          if (value != null) {
                                            if (value == 'edit') {
                                              setState(() {
                                                _editingMessageId =
                                                    message.id.toString();
                                                _editingText =
                                                    message.message ?? "";
                                              });
                                            } else if (value == 'delete') {
                                              context
                                                  .read<ChatCubit>()
                                                  .deleteChatMessage(
                                                      message.id!,
                                                      message.chatId,
                                                      2);
                                            } else if (value == 'copy') {
                                              Clipboard.setData(ClipboardData(
                                                  text: message.message ?? ""));
                                            }
                                          }
                                        });
                                      },
                                      child:
                                          const Icon(Icons.more_vert, size: 20),
                                    ),
                                  ),
                                Container(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (!isSentByUser &&
                                              user != null &&
                                              shouldShowImage)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                    DateFormat('hh:mm a')
                                                        .format(DateTime.parse(
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
                                            child: Stack(
                                              children: [
                                                IntrinsicWidth(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color: isSentByUser
                                                          ? Colors.blue[100]
                                                          : Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                isSentByUser
                                                                    ? 12
                                                                    : 0),
                                                        topRight:
                                                            Radius.circular(
                                                                isSentByUser
                                                                    ? 0
                                                                    : 12),
                                                        bottomLeft: const Radius
                                                            .circular(12),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.40,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (message.files !=
                                                                null &&
                                                            message.files!
                                                                .isNotEmpty)
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: message
                                                                  .files!
                                                                  .map((file) {
                                                                if (_isImage(file
                                                                    .path)) {
                                                                  return MouseRegion(
                                                                    cursor:
                                                                        SystemMouseCursors
                                                                            .click,
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        String updatedImagePath = file.path.replaceAll(
                                                                            "cinteraction",
                                                                            "huawei");

                                                                        _showImageDialog(
                                                                            context,
                                                                            updatedImagePath);
                                                                      },
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                                8.0),
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8.0),
                                                                          child: file.bytes != null
                                                                              ? Image.memory(
                                                                                  file.bytes!,
                                                                                  width: 200,
                                                                                  height: 200,
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : Image.network(
                                                                                  file.path.replaceAll("cinteraction", "huawei"),
                                                                                  width: 200,
                                                                                  height: 200,
                                                                                  fit: BoxFit.cover,
                                                                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.red),
                                                                                ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if (_isTextFile(
                                                                    file.path)) {
                                                                  return _buildFileButton(
                                                                      context,
                                                                      file.path,
                                                                      Icons
                                                                          .description,
                                                                      'Open TextFile');
                                                                } else {
                                                                  return _buildFileButton(
                                                                      context,
                                                                      file.path,
                                                                      Icons
                                                                          .picture_as_pdf,
                                                                      'Open PDF file');
                                                                }
                                                              }).toList()),
                                                        if (message.message !=
                                                                null &&
                                                            message.message!
                                                                .isNotEmpty)
                                                          if (_editingMessageId ==
                                                              message.id
                                                                  .toString())
                                                            TextField(
                                                              controller: TextEditingController(
                                                                  text:
                                                                      _editingText)
                                                                ..selection =
                                                                    TextSelection
                                                                        .fromPosition(
                                                                  TextPosition(
                                                                      offset: _editingText
                                                                          .length),
                                                                ),
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  _editingText =
                                                                      value;
                                                                });
                                                              },
                                                              onSubmitted:
                                                                  (value) {
                                                                _saveEditedMessage(
                                                                    message.id!,
                                                                    message
                                                                        .chatId);
                                                              },
                                                              autofocus: true,
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintText:
                                                                    'Edit message...',
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            )
                                                          else
                                                            SelectableText(
                                                              message.message!,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    'Roboto',
                                                              ),
                                                            ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _saveEditedMessage(int messageId, int chatId) {
    if (_editingText.trim().isEmpty) return;

    context
        .read<ChatCubit>()
        .editChatMessage(messageId, _editingText.trim(), chatId, 1);

    setState(() {
      _editingMessageId = null;
      _editingText = "";
    });
  }

  Widget _buildFileButton(
      BuildContext context, String fileUrl, IconData icon, String buttonText) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () {
          if (_isPdf(fileUrl)) {
            showPdfDialog(context, fileUrl);
          } else if (_isTextFile(fileUrl)) {
            openTextFile(context, fileUrl);
          } else {
            print("Nepodržan format");
          }
        },
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getFileNameFromUrl(fileUrl),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
