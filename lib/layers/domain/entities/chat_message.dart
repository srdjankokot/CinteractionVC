import 'package:file_picker/file_picker.dart';

class ChatMessage {
  ChatMessage(
      {required this.message,
      required this.displayName,
      required this.time,
      required this.avatarUrl,
      this.seen,
      this.files});

  final String message;
  final String displayName;
  final DateTime time;
  final String avatarUrl;
  final List<PlatformFile>? files;
  bool? seen;
}
