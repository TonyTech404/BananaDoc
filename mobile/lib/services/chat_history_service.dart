import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_message.dart';

class ChatHistoryService with ChangeNotifier {
  List<ChatMessage> _messages = [];
  String _currentDeficiency = '';
  DateTime? _sessionStartTime; // Track when current session started

  // Singleton pattern
  static final ChatHistoryService _instance = ChatHistoryService._internal();

  factory ChatHistoryService() {
    return _instance;
  }

  ChatHistoryService._internal() {
    _loadMessages();
    _startNewSession(); // Start a new session when service initializes
  }

  List<ChatMessage> get messages => _messages;
  String get currentDeficiency => _currentDeficiency;

  // Start a new session - clears history if switching from a different context
  void _startNewSession() {
    _sessionStartTime = DateTime.now();
  }

  // Check if we should start a new session (when switching to general chat)
  void checkAndStartNewSessionIfNeeded({bool isGeneralChat = false}) {
    if (!isGeneralChat) return;

    // If switching to general chat and we have messages from a different deficiency context
    if (_currentDeficiency.isNotEmpty && _messages.isNotEmpty) {
      // This is a new general chat session, clear old deficiency-specific history
      debugPrint(
          'Starting new general chat session - clearing old deficiency history');
      clearMessages();
      _currentDeficiency = '';
      _startNewSession();
    } else if (_currentDeficiency.isEmpty && _messages.isNotEmpty) {
      // We're in general chat mode with existing messages
      // For homepage chat, always start fresh when opening (unless actively continuing)
      // Check if last message was recent (within 5 minutes) - if not, start new session
      if (_sessionStartTime != null) {
        final timeSinceSessionStart =
            DateTime.now().difference(_sessionStartTime!);
        // If more than 5 minutes since session started, start fresh
        if (timeSinceSessionStart.inMinutes >= 5) {
          debugPrint(
              'Messages are from old session (${timeSinceSessionStart.inMinutes} minutes old) - starting new session');
          clearMessages();
          _startNewSession();
        } else {
          debugPrint(
              'Using existing general chat session (${timeSinceSessionStart.inMinutes} minutes old)');
        }
      } else {
        // No session start time recorded - likely from app restart, clear old messages
        debugPrint(
            'No session start time - clearing old messages from previous app session');
        clearMessages();
        _startNewSession();
      }
    }
  }

  // Force start a new session - clears all messages and starts fresh
  void forceNewSession() {
    debugPrint('Forcing new chat session - clearing all messages');
    clearMessagesSync(); // Use sync clear for immediate UI update
    _currentDeficiency = '';
    _startNewSession();
  }

  // Check if we should start a new session based on time elapsed
  Future<bool> shouldStartNewSession({int maxMinutes = 5}) async {
    if (_messages.isEmpty) {
      return true; // No messages, start fresh
    }

    if (_sessionStartTime == null) {
      return true; // No session time, start fresh
    }

    final timeSinceSessionStart = DateTime.now().difference(_sessionStartTime!);
    // If more than maxMinutes have passed, start fresh
    return timeSinceSessionStart.inMinutes >= maxMinutes;
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? messagesJson = prefs.getString('chat_messages');
      _currentDeficiency = prefs.getString('current_deficiency') ?? '';

      // Load session start time if available
      final sessionStartTimeMillis = prefs.getInt('session_start_time');
      if (sessionStartTimeMillis != null) {
        _sessionStartTime =
            DateTime.fromMillisecondsSinceEpoch(sessionStartTimeMillis);
      }

      if (messagesJson != null) {
        final List<dynamic> decodedMessages = jsonDecode(messagesJson);
        _messages =
            decodedMessages.map((item) => ChatMessage.fromJson(item)).toList();

        // If this is a general chat (no deficiency), clear old messages immediately
        // This ensures fresh start for homepage chat
        if (_currentDeficiency.isEmpty && _messages.isNotEmpty) {
          debugPrint('General chat detected - clearing old messages on load');
          _messages.clear();
          _sessionStartTime = null;
          // Save the cleared state immediately
          await prefs.setString('chat_messages', '[]');
          await prefs.remove('session_start_time');
          _startNewSession();
        }
        // Always notify listeners after loading (whether cleared or not)
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

      // Save session start time (or remove it if null)
      if (_sessionStartTime != null) {
        await prefs.setInt(
            'session_start_time', _sessionStartTime!.millisecondsSinceEpoch);
      } else {
        await prefs.remove('session_start_time');
      }
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
    _sessionStartTime = null; // Clear session time when clearing messages
    _saveMessages();
    notifyListeners();
  }

  // Synchronously clear messages without async save (for immediate UI update)
  void clearMessagesSync() {
    _messages.clear();
    _sessionStartTime = null;
    notifyListeners();
    // Save asynchronously in background
    _saveMessages();
  }

  void setDeficiency(String deficiency) {
    if (_currentDeficiency != deficiency) {
      // If switching to a different deficiency, start a new session
      if (_currentDeficiency.isNotEmpty && deficiency.isNotEmpty) {
        debugPrint(
            'Switching deficiency from $_currentDeficiency to $deficiency - starting new session');
        clearMessages();
        _startNewSession();
      }
      _currentDeficiency = deficiency;
      _saveMessages();
      notifyListeners();
    }
  }

  // Clear deficiency and start a new general chat session
  void startNewGeneralChatSession() {
    debugPrint('Starting new general chat session');
    clearMessages();
    _currentDeficiency = '';
    _startNewSession();
  }

  // Get all messages as formatted context for LLM
  // Only include messages from the current session
  String getContext() {
    if (_messages.isEmpty) {
      return '';
    }

    // Filter messages to only include those from current session
    // For now, we'll use all messages but in the future we could add session tracking per message
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
