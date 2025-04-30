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
import 'package:cinteraction_vc/layers/presentation/cubit/conference/conference_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/pdf_viewer_screen.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:dio/dio.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../../../../core/ui/images/image.dart';
import 'chat_dropzone.dart';

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

  Future<void> pickAndSendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: kIsWeb,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      Uint8List? fileBytes;

      if (kIsWeb) {
        fileBytes = file.bytes;
      } else if (file.bytes != null) {
        fileBytes = file.bytes;
      } else if (file.path != null) {
        File selectedFile = File(file.path!);
        fileBytes = await selectedFile.readAsBytes();
      }

      if (fileBytes != null) {
        PlatformFile fileWithBytes = PlatformFile(
          name: file.name,
          size: fileBytes.length,
          bytes: fileBytes,
        );
        await sendMessage(uploadedFiles: [fileWithBytes]);
      } else {
        print('Error: Bytes not read.');
      }
    } else {
      print('User canceled file selection');
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

  late DropzoneViewController controller;
  FocusNode messageFocusNode = FocusNode();

  Future<void> onFileDropped(dynamic event) async {
    final name = await controller.getFilename(event);
    final bytes = await controller.getFileData(event);

    await context.read<ChatCubit>().sendFile(name.toString(), bytes);
  }

  TextEditingController messageFieldController = TextEditingController();

  Future<void> sendMessage({List<PlatformFile>? uploadedFiles}) async {
    await context.read<ChatCubit>().sendChatMessage(
          messageContent: messageFieldController.text,
          uploadedFiles: uploadedFiles,
        );

    messageFieldController.text = '';
    messageFocusNode.requestFocus();
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
        // print('ProgressInWidget: ${state.uploadProgress}');
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
            //dropzone
            Expanded(
              child: Stack(
                children: [
                  ChatDropzone(
                    sendFile: sendMessage,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Container(
                            child: Expanded(
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
                                        chatDetails?.authUser.id;
                                    final user = getUserById(message.senderId);

                                    final bool shouldShowImage = index ==
                                            sortedMessages.length - 1 ||
                                        (index < sortedMessages.length - 1 &&
                                            sortedMessages[index + 1]
                                                    .senderId !=
                                                message.senderId);
                                    // print(
                                    //     'unseenMessages: ${state.chatMessages}');

                                    return VisibilityDetector(
                                      key: Key(index.toString()),
                                      onVisibilityChanged:
                                          (VisibilityInfo info) {
                                        context
                                            .read<ChatCubit>()
                                            .chatMessageSeen(message.id!);
                                      },
                                      child: MouseRegion(
                                        onEnter: (_) => setState(
                                            () => _hoverStates[index] = true),
                                        onExit: (_) => setState(
                                            () => _hoverStates[index] = false),
                                        child: Align(
                                          alignment: isSentByUser
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              if (_hoverStates[index] == true &&
                                                  isSentByUser)
                                                Positioned(
                                                  top: 0,
                                                  right:
                                                      isSentByUser ? 5 : null,
                                                  left: isSentByUser ? null : 0,
                                                  child: GestureDetector(
                                                    onTapDown: (TapDownDetails
                                                        details) {
                                                      final RenderBox overlay =
                                                          Overlay.of(context)
                                                                  .context
                                                                  .findRenderObject()
                                                              as RenderBox;
                                                      showMenu(
                                                        context: context,
                                                        position: RelativeRect
                                                            .fromRect(
                                                          details.globalPosition &
                                                              const Size(
                                                                  40, 40),
                                                          Offset.zero &
                                                              overlay.size,
                                                        ),
                                                        items: message.files !=
                                                                    null &&
                                                                message.files!
                                                                    .isNotEmpty
                                                            ? [
                                                                const PopupMenuItem(
                                                                  value:
                                                                      'delete',
                                                                  child: Text(
                                                                      'Delete'),
                                                                ),
                                                              ]
                                                            : [
                                                                const PopupMenuItem(
                                                                  value: 'edit',
                                                                  child: Text(
                                                                      'Edit'),
                                                                ),
                                                                const PopupMenuItem(
                                                                  value: 'copy',
                                                                  child: Text(
                                                                      'Copy'),
                                                                ),
                                                                const PopupMenuItem(
                                                                  value:
                                                                      'delete',
                                                                  child: Text(
                                                                      'Delete'),
                                                                ),
                                                              ],
                                                      ).then((value) {
                                                        if (value != null) {
                                                          if (value == 'edit') {
                                                            setState(() {
                                                              _editingMessageId =
                                                                  message.id
                                                                      .toString();
                                                              _editingText =
                                                                  message.message ??
                                                                      "";
                                                            });
                                                          } else if (value ==
                                                              'delete') {
                                                            context
                                                                .read<
                                                                    ChatCubit>()
                                                                .deleteChatMessage(
                                                                    message.id!,
                                                                    message
                                                                        .chatId,
                                                                    2);
                                                          } else if (value ==
                                                              'copy') {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text: message
                                                                            .message ??
                                                                        ""));
                                                          }
                                                        }
                                                      });
                                                    },
                                                    child: const Icon(
                                                        Icons.more_vert,
                                                        size: 20),
                                                  ),
                                                ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 50),
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (!isSentByUser &&
                                                            user != null &&
                                                            shouldShowImage)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  user.name
                                                                      .split(
                                                                          " ")
                                                                      .first,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Roboto',
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
                                                                Text(
                                                                  DateFormat(
                                                                          'hh:mm a')
                                                                      .format(DateTime.parse(
                                                                          message
                                                                              .createdAt)),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        10,
                                                                    fontFamily:
                                                                        'Roboto',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Align(
                                                          alignment: isSentByUser
                                                              ? Alignment
                                                                  .centerRight
                                                              : Alignment
                                                                  .centerLeft,
                                                          child: Stack(
                                                            children: [
                                                              IntrinsicWidth(
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          12),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: isSentByUser
                                                                        ? Colors.blue[
                                                                            100]
                                                                        : Colors
                                                                            .grey[200],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius.circular(
                                                                          isSentByUser
                                                                              ? 12
                                                                              : 0),
                                                                      topRight: Radius.circular(
                                                                          isSentByUser
                                                                              ? 0
                                                                              : 12),
                                                                      bottomLeft:
                                                                          const Radius
                                                                              .circular(
                                                                              12),
                                                                      bottomRight:
                                                                          const Radius
                                                                              .circular(
                                                                              12),
                                                                    ),
                                                                  ),
                                                                  constraints:
                                                                      BoxConstraints(
                                                                    maxWidth: MediaQuery.of(context)
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
                                                                          message
                                                                              .files!
                                                                              .isNotEmpty)
                                                                        MouseRegion(
                                                                          cursor:
                                                                              SystemMouseCursors.click,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: message.files!.map((file) {
                                                                                if (_isImage(file.path)) {
                                                                                  return GestureDetector(
                                                                                    onTap: () async {
                                                                                      String updatedImagePath = file.path.replaceAll("cinteraction", "huawei");

                                                                                      _showImageDialog(context, updatedImagePath);
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(top: 8.0),
                                                                                      child: ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(8.0),
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
                                                                                  );
                                                                                } else if (_isTextFile(file.path)) {
                                                                                  return _buildFileButton(context, file.path, Icons.description, 'Open TextFile');
                                                                                } else {
                                                                                  return _buildFileButton(context, file.path, Icons.picture_as_pdf, 'Open PDF file');
                                                                                }
                                                                              }).toList()),
                                                                        ),
                                                                      if (message.message !=
                                                                              null &&
                                                                          message
                                                                              .message!
                                                                              .isNotEmpty)
                                                                        if (_editingMessageId ==
                                                                            message.id.toString())
                                                                          TextField(
                                                                            controller: TextEditingController(text: _editingText)
                                                                              ..selection = TextSelection.fromPosition(
                                                                                TextPosition(offset: _editingText.length),
                                                                              ),
                                                                            onChanged:
                                                                                (value) {
                                                                              setState(() {
                                                                                _editingText = value;
                                                                              });
                                                                            },
                                                                            onSubmitted:
                                                                                (value) {
                                                                              _saveEditedMessage(message.id!, message.chatId);
                                                                            },
                                                                            autofocus:
                                                                                true,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              hintText: 'Edit message...',
                                                                              border: OutlineInputBorder(),
                                                                            ),
                                                                          )
                                                                        else
                                                                          Linkify(
                                                                            onOpen:
                                                                                (link) async {
                                                                              final uri = Uri.parse(link.url);
                                                                              if (await canLaunchUrl(uri)) {
                                                                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                                              }
                                                                            },
                                                                            text:
                                                                                message.message!,
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 15,
                                                                              fontFamily: 'Roboto',
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
                                      ),
                                    );
                                  },
                                ),
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),

            if (state.uploadProgress > 0 && state.uploadProgress != 1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.uploadProgress > 0.0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'Uploading files...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: state.uploadProgress == 1.0
                                ? Colors.green
                                : Colors.blueGrey,
                          ),
                        ),
                      ),
                    // Text(
                    //   'Upload: ${(state.uploadProgress * 100).toStringAsFixed(0)}%',
                    //   style: const TextStyle(
                    //       fontSize: 16, fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),
              ),

            const SizedBox(
              height: 5,
            ),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.read<ChatCubit>().toggleEmojiVisibility();
                  },
                ),
                Expanded(
                  child: TextField(
                    focusNode: messageFocusNode,
                    controller: messageFieldController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 8,
                    onTap: () {
                      if (state.isEmojiVisible!) {
                        context.read<ChatCubit>().showEmoji(false);
                      }
                    },
                    onEditingComplete: () {
                      if (messageFieldController.text.trim().isNotEmpty) {
                        sendMessage();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Send a message",
                      suffixIcon: IconButton(
                        onPressed: () {
                          sendMessage();
                        },
                        icon: imageSVGAsset('icon_send') as Widget,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await pickAndSendFile();
                  },
                  icon: imageSVGAsset('three_dots') as Widget,
                ),
              ],
            ),

            if (state.isEmojiVisible!)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    messageFieldController.text += emoji.emoji;
                    messageFieldController.selection =
                        TextSelection.fromPosition(
                      TextPosition(offset: messageFieldController.text.length),
                    );
                  },
                  config: Config(
                    height: 256,
                    // bgColor: const Color(0xFFF2F2F2),
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      // Issue: https://github.com/flutter/flutter/issues/28894
                      emojiSizeMax: 28 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.20
                              : 1.0),
                    ),
                    viewOrderConfig: const ViewOrderConfig(
                      top: EmojiPickerItem.categoryBar,
                      middle: EmojiPickerItem.emojiView,
                      bottom: EmojiPickerItem.searchBar,
                    ),
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(),
                    bottomActionBarConfig: const BottomActionBarConfig(),
                    searchViewConfig: const SearchViewConfig(),
                  ),
                ),
              ),

            //input
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
