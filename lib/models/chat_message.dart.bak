class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });

  // Create a ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
    );
  }

  // Convert ChatMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
    };
  }
}
