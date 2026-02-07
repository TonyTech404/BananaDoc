import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../services/chat_history_service.dart';
import '../services/llm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final LLMService _llmService = LLMService();

  // Use local messages for general chat (like chat_screen does)
  final List<ChatMessage> _localMessages = [];
  String _conversationHistory = ""; // Track conversation for context

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      _llmService.currentLocale = localeProvider.locale;

      // Clear backend server context for fresh start
      await _llmService.clearBackendContext();

      // For general chat, start with empty local messages (fresh session)
      // Only use ChatHistoryService for deficiency-specific chats
      final chatService =
          Provider.of<ChatHistoryService>(context, listen: false);
      if (chatService.currentDeficiency.isEmpty) {
        // General chat - use local messages, start fresh
        _localMessages.clear();
        _conversationHistory = "";
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Check if user is near the bottom of the chat (within 50 pixels - stricter like chat_screen)
  bool _isNearBottom() {
    if (!_scrollController.hasClients) return false;
    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    // Consider "near bottom" only if within 50 pixels (stricter check)
    return (maxScroll - currentScroll) < 50;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Update conversation history (like chat_screen does)
  void _updateConversationHistory(String speaker, String message) {
    _conversationHistory += "$speaker: $message\n\n";
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatService = Provider.of<ChatHistoryService>(context, listen: false);
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    _llmService.currentLocale = locale;

    // Check if user is near bottom before adding message
    final bool wasNearBottom = _isNearBottom();

    // Add user message - use local messages for general chat, ChatHistoryService for deficiency chat
    if (chatService.currentDeficiency.isEmpty) {
      // General chat - use local messages
      setState(() {
        _localMessages.add(ChatMessage(text: message, isUser: true));
        _isLoading = true;
      });
      _updateConversationHistory("User", message);
    } else {
      // Deficiency chat - use ChatHistoryService
      chatService.addMessage(ChatMessage(text: message, isUser: true));
      setState(() {
        _isLoading = true;
      });
    }

    _messageController.clear();

    // Auto-scroll if near bottom
    if (wasNearBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    try {
      String response;

      if (chatService.currentDeficiency.isNotEmpty) {
        // Deficiency-specific chat - use ChatHistoryService
        // Get the full conversation context - this is critical for follow-up questions
        final conversationContext = chatService.getContext();
        debugPrint(
            'USING CONVERSATION CONTEXT (${conversationContext.length} chars)');

        // IMPROVED: Check if this is a follow-up type question that requires strong contextual handling
        final bool isFollowUp = _isFollowUpOrActionQuestion(
            message.toLowerCase().trim(), locale.languageCode == 'tl');
        debugPrint('Is follow-up or action question: $isFollowUp');

        if (isFollowUp) {
          debugPrint(
              'ENHANCED HANDLING: Follow-up question about ${chatService.currentDeficiency}');

          // For very simple action questions, get direct treatment instructions
          if (_isActionQuestion(message.toLowerCase().trim())) {
            debugPrint(
                'ACTION QUESTION DETECTED: Getting treatment for ${chatService.currentDeficiency}');
            response = await _llmService
                .getTreatmentRecommendation(chatService.currentDeficiency);
          }
          // For why/cause questions
          else if (_isCauseQuestion(message.toLowerCase().trim())) {
            debugPrint(
                'CAUSE QUESTION DETECTED: Getting explanation for ${chatService.currentDeficiency}');
            response = await _llmService.answerFarmerQuestion(
                chatService.currentDeficiency,
                "why do plants have "
                "${chatService.currentDeficiency}"
                " deficiency?",
                context: conversationContext);
          }
          // For prevention questions
          else if (_isPreventionQuestion(message.toLowerCase().trim())) {
            debugPrint(
                'PREVENTION QUESTION DETECTED: Getting prevention for ${chatService.currentDeficiency}');
            response = await _llmService.answerFarmerQuestion(
                chatService.currentDeficiency,
                "how to prevent "
                "${chatService.currentDeficiency}"
                " deficiency?",
                context: conversationContext);
          }
          // For any other follow-up questions, send with context
          else {
            debugPrint(
                'FOLLOW-UP QUESTION: Using enhanced contextual handling');
            // Specifically craft the prompt to maintain context
            String enhancedMessage = locale.languageCode == 'tl'
                ? "Tungkol sa ${chatService.currentDeficiency} deficiency: $message"
                : "Regarding the ${chatService.currentDeficiency} deficiency: $message";

            response = await _llmService.answerFarmerQuestion(
                chatService.currentDeficiency, enhancedMessage,
                context: conversationContext);
          }
        } else {
          // For more complex questions, use the regular flow with context awareness
          response = await _llmService.answerFarmerQuestion(
              chatService.currentDeficiency, message,
              context: conversationContext);
        }

        debugPrint('RESPONSE LENGTH: ${response.length}');

        // Add response to ChatHistoryService
        chatService.addMessage(ChatMessage(text: response, isUser: false));
      } else {
        // General chat - build context like chat_screen does
        debugPrint('GENERAL CHAT: Using backend chat server');
        debugPrint('Current locale: ${locale.languageCode}');

        // Build context similar to chat_screen - language preference FIRST and VERY prominent
        final isTagalog = locale.languageCode == 'tl';

        // Build the full query with language preference at the very top
        String fullQuery = "";

        // CRITICAL: Put language instruction FIRST and make it VERY prominent
        if (isTagalog) {
          fullQuery = "⚠️ CRITICAL LANGUAGE REQUIREMENT - READ THIS FIRST ⚠️\n"
              "==================================================\n"
              "USER LANGUAGE PREFERENCE: TAGALOG/FILIPINO\n"
              "MANDATORY INSTRUCTION: ALL your responses MUST be EXCLUSIVELY in Tagalog/Filipino.\n"
              "DO NOT use any English words.\n"
              "DO NOT mix languages.\n"
              "DO NOT translate Tagalog terms to English.\n"
              "RESPOND ONLY IN TAGALOG/FILIPINO LANGUAGE.\n"
              "==================================================\n\n";
        } else {
          fullQuery = "⚠️ CRITICAL LANGUAGE REQUIREMENT - READ THIS FIRST ⚠️\n"
              "==================================================\n"
              "USER LANGUAGE PREFERENCE: ENGLISH\n"
              "MANDATORY INSTRUCTION: ALL your responses MUST be EXCLUSIVELY in English.\n"
              "DO NOT use any Tagalog/Filipino words.\n"
              "DO NOT mix languages.\n"
              "RESPOND ONLY IN ENGLISH LANGUAGE.\n"
              "==================================================\n\n";
        }

        // Add conversation history if available
        if (_conversationHistory.isNotEmpty) {
          fullQuery += "CONVERSATION HISTORY:\n$_conversationHistory\n\n";
        }

        // Add the user's question
        fullQuery += "User question: $message";

        debugPrint('Full query length: ${fullQuery.length} chars');
        debugPrint('Language preference: ${isTagalog ? "Tagalog" : "English"}');

        // Use LLMService which will call the backend chat API
        // Pass the full query (with language preference at top) as the question
        // This ensures language preference is prioritized
        _llmService.currentLocale = locale;

        // Call answerFarmerQuestion with the full query as context
        // The backend will receive: context + question, so language preference will be first
        response = await _llmService.answerFarmerQuestion(
          'unknown',
          message,
          context: fullQuery,
        );

        debugPrint('Response received, length: ${response.length}');
        debugPrint(
            'Response preview: ${response.substring(0, response.length > 100 ? 100 : response.length)}');

        // Add response to local messages
        setState(() {
          _localMessages.add(ChatMessage(text: response, isUser: false));
        });
        _updateConversationHistory("AI", response);
      }

      // Debug print final response
      debugPrint('==== FINAL RESPONSE ====');
      debugPrint(
          response.substring(0, response.length > 100 ? 100 : response.length));

      setState(() {
        _isLoading = false;
      });

      // Only auto-scroll if user is near the bottom (reading new messages)
      final bool stillNearBottom = _isNearBottom();
      if (stillNearBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      debugPrint('Error in HomeScreen: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error stack: ${StackTrace.current}');

      // Get locale for error message
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      String errorMessage;

      // Check for various error types and provide appropriate messages
      final errorString = e.toString().toLowerCase();
      final isNetworkError = errorString.contains('failed') ||
          errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('timeout') ||
          errorString.contains('socket') ||
          errorString.contains('http') ||
          errorString.contains('api error');

      if (isNetworkError ||
          errorString.contains('failed to analyze') ||
          errorString.contains('api error')) {
        if (locale.languageCode == 'tl') {
          errorMessage =
              'Paumanhin, nagkaroon ng problema sa koneksyon sa AI service. Pakisuri ang iyong koneksyon sa internet at subukang muli.';
        } else {
          errorMessage =
              'Sorry, there was a problem connecting to the AI service. Please check your network connection and try again.';
        }
      } else {
        // Generic error message for other types of errors
        if (locale.languageCode == 'tl') {
          errorMessage =
              'Paumanhin, may naganap na error habang pinoproseso ang iyong mensahe. Pakisubukang muli mamaya.';
        } else {
          errorMessage =
              'Sorry, an error occurred while processing your message. Please try again later.';
        }
      }

      // Add error message
      if (chatService.currentDeficiency.isEmpty) {
        setState(() {
          _localMessages.add(ChatMessage(text: errorMessage, isUser: false));
        });
        _updateConversationHistory("AI", errorMessage);
      } else {
        chatService.addMessage(ChatMessage(text: errorMessage, isUser: false));
      }

      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  // Helper to detect if this is an action question
  bool _isActionQuestion(String text) {
    // Extremely simple Tagalog action questions
    final tagalogActionPatterns = [
      'anong gagawin',
      'ano gagawin',
      'paano gamutin',
      'paano to',
      'paano ito',
      'ano dapat',
      'dapat gawin',
      'anong solusyon',
      'ano ang lunas',
      'paano ayusin',
      'paano',
      'gagawin ko',
      'gawin ko',
      'ano una',
      'ngayon',
      'simula',
      'tulungan'
    ];

    for (String pattern in tagalogActionPatterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }

    // English action questions
    final englishActionPatterns = [
      'what should i do',
      'how to fix',
      'how to treat',
      'what to do',
      'what now',
      'fix this',
      'treat this',
      'how do i',
      'steps',
      'solution',
      'handle this',
      'next'
    ];

    for (String pattern in englishActionPatterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  // Helper to detect if this is a cause question
  bool _isCauseQuestion(String text) {
    // Tagalog cause questions
    final tagalogCausePatterns = [
      'bakit',
      'sanhi',
      'dahilan',
      'galing saan',
      'paano nangyari',
      'anong dahilan'
    ];

    for (String pattern in tagalogCausePatterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }

    // English cause questions
    final englishCausePatterns = [
      'why',
      'cause',
      'reason',
      'source',
      'how did this happen'
    ];

    for (String pattern in englishCausePatterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  // Helper to detect if this is a prevention question
  bool _isPreventionQuestion(String text) {
    // Tagalog prevention questions
    final tagalogPreventionPatterns = [
      'iwasan',
      'maiwasan',
      'pag-iwas',
      'hindi mangyari',
      'hindi maulit',
      'paano pigilan'
    ];

    for (String pattern in tagalogPreventionPatterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }

    // English prevention questions
    final englishPreventionPatterns = [
      'prevent',
      'avoid',
      'stop',
      'not happen again',
      'future',
      'keep from'
    ];

    for (String pattern in englishPreventionPatterns) {
      if (text.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  // Helper to detect follow-up questions or action questions
  bool _isFollowUpOrActionQuestion(String text, bool isTagalog) {
    // First check if it's an action question
    if (_isActionQuestion(text)) {
      return true;
    }

    // Check for follow-up patterns
    if (isTagalog) {
      final List<String> followUpPatterns = [
        'so ano',
        'so anong',
        'so paano',
        'ano pa',
        'ano ulit',
        'paano ulit',
        'ganun ba',
        'talaga',
        'tapos',
        'sige',
        'oo',
        'hindi',
        'eh paano',
        'eh ano',
        'at ano',
        'at paano',
        'ano ang',
        'paano ang',
        'ano na',
        'pano',
        'e di'
      ];

      for (String pattern in followUpPatterns) {
        if (text.startsWith(pattern) ||
            text.contains(' $pattern ') ||
            text == pattern) {
          return true;
        }
      }

      // Very short Tagalog questions are usually follow-ups
      if (text.length < 15) {
        return true;
      }
    } else {
      // English follow-up patterns
      final List<String> followUpPatterns = [
        'so what',
        'so how',
        'and then',
        'what else',
        'how else',
        'really',
        'ok',
        'okay',
        'yes',
        'no',
        'just',
        'but',
        'and',
        'so',
        'then',
        'now',
        'next',
        'what now',
        'what about',
        'how about',
        'is that all',
        'that\'s it'
      ];

      for (String pattern in followUpPatterns) {
        if (text.startsWith(pattern) ||
            text.contains(' $pattern ') ||
            text == pattern) {
          return true;
        }
      }

      // Very short English questions are usually follow-ups
      if (text.length < 12) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: true);
    final chatService = Provider.of<ChatHistoryService>(context, listen: true);

    // Use local messages for general chat, ChatHistoryService for deficiency chat
    final messages = chatService.currentDeficiency.isEmpty
        ? _localMessages
        : chatService.messages;

    // Update LLMService with current locale
    _llmService.currentLocale = localeProvider.locale;

    String currentDeficiency = chatService.currentDeficiency;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentDeficiency.isNotEmpty
            ? '$currentDeficiency Assistant'
            : localizations.appTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'en') {
                localeProvider.setLocale(const Locale('en', ''));
                // Update language preference
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('selected_language', 'en');
                // Update LLMService locale
                _llmService.currentLocale = const Locale('en', '');
                // Clear local messages and conversation history for fresh start
                setState(() {
                  _localMessages.clear();
                  _conversationHistory = "";
                });
              } else if (value == 'tl') {
                localeProvider.setLocale(const Locale('tl', ''));
                // Update language preference
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('selected_language', 'tl');
                // Update LLMService locale
                _llmService.currentLocale = const Locale('tl', '');
                // Clear local messages and conversation history for fresh start
                setState(() {
                  _localMessages.clear();
                  _conversationHistory = "";
                });
              } else if (value == 'clear') {
                if (chatService.currentDeficiency.isEmpty) {
                  // Clear local messages for general chat
                  setState(() {
                    _localMessages.clear();
                    _conversationHistory = "";
                  });
                } else {
                  // Clear ChatHistoryService for deficiency chat
                  chatService.clearMessages();
                  chatService.setDeficiency('');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    if (localeProvider.locale.languageCode == 'en')
                      const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(localizations.english),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tl',
                child: Row(
                  children: [
                    if (localeProvider.locale.languageCode == 'tl')
                      const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(localizations.filipino),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline),
                    const SizedBox(width: 8),
                    Text(localizations.clearChatHistory),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
            tooltip: localizations.selectLanguage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Color(0xFF4CAF50),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '🍌 ${localizations.consultant}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            localizations.welcomeMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildThinkingIndicator(localeProvider),
            ),
          _buildMessageInput(localizations),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.9)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: message.isUser
            ? Text(
                message.text,
                style: const TextStyle(color: Colors.white),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                  h1: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  h2: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  h3: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  listBullet: TextStyle(
                    color: Colors.black.withValues(alpha: 0.8),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildThinkingIndicator(LocaleProvider localeProvider) {
    final isTagalog = localeProvider.locale.languageCode == 'tl';
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF4CAF50),
          child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  isTagalog ? 'Nag-iisip ang AI...' : 'AI is thinking...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: localizations.messageHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
