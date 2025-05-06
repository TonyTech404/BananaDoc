import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';

class ChatHistoryService with ChangeNotifier {
  List<ChatMessage> _messages = [];
  String _currentDeficiency = '';

  // Singleton pattern
  static final ChatHistoryService _instance = ChatHistoryService._internal();

  factory ChatHistoryService() {
    return _instance;
  }

  ChatHistoryService._internal() {
    _loadMessages();
  }

  List<ChatMessage> get messages => _messages;
  String get currentDeficiency => _currentDeficiency;

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? messagesJson = prefs.getString('chat_messages');
      _currentDeficiency = prefs.getString('current_deficiency') ?? '';

      if (messagesJson != null) {
        final List<dynamic> decodedMessages = jsonDecode(messagesJson);
        _messages =
            decodedMessages.map((item) => ChatMessage.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String messagesJson =
          jsonEncode(_messages.map((msg) => msg.toJson()).toList());
      await prefs.setString('chat_messages', messagesJson);
      await prefs.setString('current_deficiency', _currentDeficiency);
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    _saveMessages();
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    _saveMessages();
    notifyListeners();
  }

  void setDeficiency(String deficiency) {
    if (_currentDeficiency != deficiency) {
      _currentDeficiency = deficiency;
      _saveMessages();
      notifyListeners();
    }
  }

  // Get all messages as formatted context for LLM
  String getContext() {
    if (_messages.isEmpty) {
      return '';
    }

    // Use more messages for better context
    final lastMessages = _messages.length <= 15
        ? _messages
        : _messages.sublist(_messages.length - 15);

    // Create a formatted conversation history with roles clearly marked
    String context = '===Current deficiency: $_currentDeficiency===\n\n';

    // Add important context about the deficiency type if it exists
    if (_currentDeficiency.isNotEmpty) {
      context += 'IMPORTANT SYSTEM INSTRUCTIONS:\n';
      context +=
          '1. This conversation is about $_currentDeficiency deficiency in banana plants.\n';
      context += '2. ALWAYS maintain context from previous messages.\n';
      context +=
          '3. ALWAYS reference the $_currentDeficiency deficiency in your answers.\n';
      context += '4. RESPOND in a PROFESSIONAL manner suitable for farmers.\n';
      context += '5. DO NOT use casual language like "naku pare" or slang.\n';
      context +=
          '6. REMEMBER: The user has already been diagnosed with $_currentDeficiency deficiency.\n';
      context +=
          '7. FOCUS on providing SPECIFIC ADVICE related to $_currentDeficiency deficiency management, treatment, or prevention.\n';
      context +=
          '8. When the user asks follow-up questions, ASSUME they are still asking about $_currentDeficiency deficiency.\n';
      context +=
          '9. For questions like "what should I do?", "anong gagawin ko?", or other simple follow-ups, provide specific $_currentDeficiency deficiency treatment steps.\n\n';
    }

    // Add last messages with timestamps and clear role markers
    context += "===CONVERSATION HISTORY===\n";
    context += lastMessages.map((msg) {
      return "${msg.isUser ? 'USER' : 'ASSISTANT'}: ${msg.text}";
    }).join('\n\n');

    // Additional reminder at the end for contextual awareness
    if (_currentDeficiency.isNotEmpty) {
      context += '\n\n===FINAL REMINDER===\n';
      context +=
          'This is an ongoing conversation about $_currentDeficiency deficiency in banana plants.\n';
      context +=
          'Provide helpful, specific advice about $_currentDeficiency deficiency based on the current question and previous context.\n';
      context += 'Do not start from scratch as if it is a new conversation.\n';
    }

    return context;
  }
}
