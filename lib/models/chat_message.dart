enum ChatSender { user, ai }

class ChatMessage {
  ChatMessage({required this.sender, required this.content, required this.timestamp});

  final ChatSender sender;
  final String content;
  final DateTime timestamp;
}
