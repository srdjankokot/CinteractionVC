class ChatMessage{
   ChatMessage({required this.message, required this.displayName, required this.time, required this.avatarUrl, this.seen});

  final String message;
  final String displayName;
  final DateTime time;
  final String avatarUrl;
   bool? seen;
}