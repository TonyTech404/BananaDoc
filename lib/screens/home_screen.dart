import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatService = Provider.of<ChatHistoryService>(context, listen: false);

    // Debug output for diagnostics
    print('====== SENDING MESSAGE ======');
    print('Message: $message');
    print('Current deficiency: ${chatService.currentDeficiency}');
    print('Has context: ${chatService.messages.isNotEmpty}');
    print('Message count: ${chatService.messages.length}');

    // Add user message to history
    chatService.addMessage(ChatMessage(
      text: message,
      isUser: true,
    ));

    setState(() {
      _isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      String response;
      // Set the current locale in the LLM service
      final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
      _llmService.currentLocale = locale;
      print('Current locale: ${locale.languageCode}');

      // CRITICAL FIX: Handling simple questions about deficiencies directly
      // without going through external APIs
      if (chatService.currentDeficiency.isNotEmpty) {
        // Get the full conversation context - this is critical for follow-up questions
        final conversationContext = chatService.getContext();
        print(
            'USING CONVERSATION CONTEXT (${conversationContext.length} chars)');

        // IMPROVED: Check if this is a follow-up type question that requires strong contextual handling
        final bool isFollowUp = _isFollowUpOrActionQuestion(
            message.toLowerCase().trim(), locale.languageCode == 'tl');
        print('Is follow-up or action question: $isFollowUp');

        if (isFollowUp) {
          print(
              'ENHANCED HANDLING: Follow-up question about ${chatService.currentDeficiency}');

          // For very simple action questions, get direct treatment instructions
          if (_isActionQuestion(message.toLowerCase().trim())) {
            print(
                'ACTION QUESTION DETECTED: Getting treatment for ${chatService.currentDeficiency}');
            response = await _llmService
                .getTreatmentRecommendation(chatService.currentDeficiency);
          }
          // For why/cause questions
          else if (_isCauseQuestion(message.toLowerCase().trim())) {
            print(
                'CAUSE QUESTION DETECTED: Getting explanation for ${chatService.currentDeficiency}');
            response = await _llmService.answerFarmerQuestion(
                chatService.currentDeficiency,
                "why do plants have ${chatService.currentDeficiency} deficiency?",
                context: conversationContext);
          }
          // For prevention questions
          else if (_isPreventionQuestion(message.toLowerCase().trim())) {
            print(
                'PREVENTION QUESTION DETECTED: Getting prevention for ${chatService.currentDeficiency}');
            response = await _llmService.answerFarmerQuestion(
                chatService.currentDeficiency,
                "how to prevent ${chatService.currentDeficiency} deficiency?",
                context: conversationContext);
          }
          // For any other follow-up questions, send with context
          else {
            print('FOLLOW-UP QUESTION: Using enhanced contextual handling');
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

        print('RESPONSE LENGTH: ${response.length}');
      } else {
        // For initial analysis when no deficiency is identified yet
        print('NO DEFICIENCY DETECTED YET: Using general analysis');
        final localeProvider =
            Provider.of<LocaleProvider>(context, listen: false);
        final GeminiService geminiService = GeminiService();

        final analysisResult = await geminiService.analyzeLeafCondition(
          description: message,
          locale: localeProvider.locale,
        );

        // CRITICAL: If Gemini detected a deficiency, IMMEDIATELY set it
        String detectedDeficiency = analysisResult.deficiencyType;
        if (detectedDeficiency.isNotEmpty && detectedDeficiency != 'Unknown') {
          print('SETTING DEFICIENCY FROM ANALYSIS: $detectedDeficiency');
          chatService.setDeficiency(detectedDeficiency);

          // Since we now know the deficiency, provide a proper explanation
          String explanation = await _llmService.getDeficiencyExplanation(
              detectedDeficiency, analysisResult.confidence);
          String treatment =
              await _llmService.getTreatmentRecommendation(detectedDeficiency);

          // Combine diagnosis with treatment
          response = '$explanation\n\n$treatment';
        } else {
          response = analysisResult.diagnosis;
        }
      }

      // Debug print final response
      print('==== FINAL RESPONSE ====');
      print(
          response.substring(0, response.length > 100 ? 100 : response.length));

      // Add assistant response to history
      chatService.addMessage(ChatMessage(
        text: response,
        isUser: false,
      ));

      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      print('Error in HomeScreen: $e');

      String errorMessage = e.toString();
      if (errorMessage.contains('Failed to analyze leaf condition')) {
        final locale =
            Provider.of<LocaleProvider>(context, listen: false).locale;
        if (locale.languageCode == 'tl') {
          errorMessage =
              'Paumanhin, nagkaroon ng problema sa koneksyon sa AI service. Pakisuri ang iyong koneksyon sa internet at subukang muli.';
        } else {
          errorMessage =
              'Sorry, there was a problem connecting to the AI service. Please check your network connection and try again.';
        }
      }

      // Add error message to history
      chatService.addMessage(ChatMessage(
        text: errorMessage,
        isUser: false,
      ));

      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    }
  }

  // Helper to detect if this is a simple question we should handle directly
  bool _isSimpleQuestion(String text) {
    return _isActionQuestion(text) ||
        _isCauseQuestion(text) ||
        _isPreventionQuestion(text) ||
        text.length < 12; // Very short questions
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
    final messages = chatService.messages;

    // Create an instance of LLMService
    final llmService = LLMService();
    // Update LLMService with current locale
    llmService.currentLocale = localeProvider.locale;

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
                llmService.currentLocale = const Locale('en', '');
              } else if (value == 'tl') {
                localeProvider.setLocale(const Locale('tl', ''));
                // Update language preference
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('selected_language', 'tl');
                // Update LLMService locale
                llmService.currentLocale = const Locale('tl', '');
              } else if (value == 'clear') {
                chatService.clearMessages();
                chatService.setDeficiency('');
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
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
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
            color: Colors.black.withOpacity(0.1),
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
