import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import '../../../../../assets/colors/Colors.dart';
import '../../../../../core/app/style.dart';
import '../../../../../core/extension/color.dart';

class ChatDropzone extends StatefulWidget {
  final Widget child;
  final Future<void> Function({List<PlatformFile>? uploadedFiles}) sendFile;

  const ChatDropzone({Key? key, required this.child, required this.sendFile})
      : super(key: key);

  @override
  _ChatDropzoneState createState() => _ChatDropzoneState();
}

class _ChatDropzoneState extends State<ChatDropzone> {
  late DropzoneViewController controller;
  bool isDragging = false;

  Future<void> onFileDropped(dynamic event) async {
    setState(() => isDragging = false);

    final name = await controller.getFilename(event);
    final bytes = await controller.getFileData(event);
    final size = bytes.length;

    print("Dodati fajl: $name");

    final droppedFile = PlatformFile(
      name: name,
      size: size,
      bytes: bytes,
    );

    await widget.sendFile(uploadedFiles: [droppedFile]);
    // await sendMessage(uploadedFiles: [droppedFile]);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (kIsWeb)
          DropzoneView(
            onCreated: (ctrl) => controller = ctrl,
            onDropFile: onFileDropped,
            onHover: () => setState(() => isDragging = true),
            onLeave: () => setState(() => isDragging = false),
          ),
        if (isDragging)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: ColorUtil.getColor(context)!.kBlue,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: ColorUtil.getColor(context)!.kBlue.withOpacity(0.1),
              ),
              child:  Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_upload, size: 50, color: ColorUtil.getColor(context)!.kBlue),
                    SizedBox(height: 8),
                    Text(
                      "Drop files to send",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorUtil.getColor(context)!.kBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}
