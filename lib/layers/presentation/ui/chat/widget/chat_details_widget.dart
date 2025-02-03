import 'dart:convert';
import 'dart:io';

import 'package:cinteraction_vc/assets/colors/Colors.dart';
import 'package:cinteraction_vc/core/extension/context.dart';
import 'package:cinteraction_vc/core/io/network/models/participant.dart';
import 'package:cinteraction_vc/layers/data/dto/chat/chat_detail_dto.dart';
import 'package:cinteraction_vc/layers/domain/entities/user.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_cubit.dart';
import 'package:cinteraction_vc/layers/presentation/cubit/chat/chat_state.dart';
import 'package:cinteraction_vc/layers/presentation/ui/chat/widget/pdf_viewer_screen.dart';
import 'package:cinteraction_vc/layers/presentation/ui/profile/ui/widget/user_image.dart';
import 'package:dio/dio.dart';
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

  bool _isImage(String url) {
    return url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.gif');
  }

  bool _isPdf(String url) {
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

  void _openPdf(BuildContext context, String pdfUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfUrl: pdfUrl),
      ),
    );
  }

  void _openTextFile(BuildContext context, String fileUrl) async {
    try {
      Dio dio = Dio();
      print('FileeUrl: $fileUrl');
      Response response = await dio.get(fileUrl);

      if (response.statusCode == 200) {
        String fileContent =
            response.data.toString(); // Dobijanje sadržaja kao string

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Tekstualni fajl"),
            content: SingleChildScrollView(child: Text(fileContent)),
            actions: [
              TextButton(
                child: const Text("Zatvori"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        print("Greška pri učitavanju fajla: ${response.statusCode}");
      }
    } catch (e) {
      print("Došlo je do greške: $e");
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
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
                                          bottomRight:
                                              const Radius.circular(12),
                                        ),
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Prikaz poruke ako postoji
                                          if (message.message != null &&
                                              message.message!.isNotEmpty)
                                            Text(
                                              message.message!,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),

                                          // Prikaz fajlova ako postoje
                                          if (message.filePath != null &&
                                              message.filePath!.isNotEmpty)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: message.filePath!
                                                  .map((fileUrl) {
                                                if (_isImage(fileUrl)) {
                                                  return GestureDetector(
                                                    onTap: () =>
                                                        _showImageDialog(
                                                            context, fileUrl),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: Image.network(
                                                          fileUrl,
                                                          width: 200,
                                                          height: 200,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              const Icon(
                                                                  Icons
                                                                      .image_not_supported,
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else if (_isPdf(fileUrl)) {
                                                  return _buildFileButton(
                                                      context,
                                                      fileUrl,
                                                      Icons.picture_as_pdf,
                                                      'Otvori PDF');
                                                } else if (_isTextFile(
                                                    fileUrl)) {
                                                  return _buildFileButton(
                                                      context,
                                                      fileUrl,
                                                      Icons.description,
                                                      'Otvori Tekst');
                                                } else {
                                                  return _buildFileButton(
                                                      context,
                                                      fileUrl,
                                                      Icons.attach_file,
                                                      'Otvori Fajl');
                                                }
                                              }).toList(),
                                            ),
                                        ],
                                      )),
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

  Widget _buildFileButton(
      BuildContext context, String fileUrl, IconData icon, String buttonText) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: GestureDetector(
        onTap: () {
          if (_isPdf(fileUrl)) {
            _openPdf(context, fileUrl);
          } else if (_isTextFile(fileUrl)) {
            _openTextFile(context, fileUrl);
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
