class ChatMessage{
  const ChatMessage({required this.message, required this.displayName, required this.time, required this.avatarUrl, required this.seen});

  final String message;
  final String displayName;
  final DateTime time;
  final String avatarUrl;
  final bool seen;
}