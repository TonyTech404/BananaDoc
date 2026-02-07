import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../services/llm_service.dart';
import '../models/leaf_analysis_result.dart';
import '../services/offline_deficiency_service.dart';
import '../providers/locale_provider.dart';
import '../widgets/farmer_language_selector.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final LeafAnalysisResult? analysisResult;
  final String? initialMessage;

  const ChatScreen({
    Key? key,
    this.analysisResult,
    this.initialMessage,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final LLMService _llmService = LLMService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isLoadingInitialMessages =
      true; // Track if initial messages are loading

  late LeafAnalysisResult? _currentAnalysis;

  // Add a conversation history string to maintain context
  String _conversationHistory = "";

  @override
  void initState() {
    super.initState();

    _currentAnalysis = widget.analysisResult;

    if (_currentAnalysis == null) {
      final offlineService =
          Provider.of<OfflineDeficiencyService>(context, listen: false);
      _currentAnalysis = offlineService.lastAnalysisResult;
    }

    // Set the locale for LLMService before generating initial messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      _llmService.currentLocale = localeProvider.locale;
      _addInitialMessages();
    });
  }

  void _addInitialMessages() async {
    // Disable auto-scroll during initial message loading
    _isLoadingInitialMessages = true;

    if (widget.initialMessage != null) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: widget.initialMessage!,
            isUser: false,
          ),
        );
        // Add initial message to conversation history
        _updateConversationHistory("AI", widget.initialMessage!);
      });
    }

    if (_currentAnalysis != null) {
      // Generate welcome message based on current locale
      final String welcomeMessage;
      if (_llmService.currentLocale?.languageCode == 'tl') {
        welcomeMessage =
            'Ako ay makakatulong sa iyong mga katanungan tungkol sa kakulangan ng ${_currentAnalysis!.deficiencyType} sa iyong mga puno ng saging. Ano ang nais mong malaman?';
      } else {
        welcomeMessage =
            'I can help answer your questions about ${_currentAnalysis!.deficiencyType} deficiency in your banana plants. What would you like to know?';
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: welcomeMessage,
            isUser: false,
          ),
        );
        // Add welcome message to conversation history
        _updateConversationHistory("AI", welcomeMessage);
      });

      setState(() {
        _isLoading = true;
      });

      final explanation = await _llmService.getDeficiencyExplanation(
        _currentAnalysis!.deficiencyType,
        _currentAnalysis!.confidence,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: explanation,
            isUser: false,
          ),
        );
        _isLoading = false;
        // Add explanation to conversation history
        _updateConversationHistory("AI", explanation);
      });

      setState(() {
        _isLoading = true;
      });

      final treatment = await _llmService.getTreatmentRecommendation(
        _currentAnalysis!.deficiencyType,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: treatment,
            isUser: false,
          ),
        );
        _isLoading = false;
        // Add treatment to conversation history
        _updateConversationHistory("AI", treatment);
      });
    } else {
      // Generate general welcome message based on current locale
      final String welcomeMessage;
      if (_llmService.currentLocale?.languageCode == 'tl') {
        welcomeMessage =
            'Mabuhay! Makakatulong ako sa mga isyu ng nutrisyon ng iyong mga halaman ng saging. Mangyaring suriin muna ang larawan ng dahon o magtanong ng pangkalahatang mga katanungan.';
      } else {
        welcomeMessage =
            'Welcome! I can help with banana plant nutrition issues. Please analyze a leaf image first or ask general questions.';
      }

      setState(() {
        _messages.add(
          ChatMessage(
            text: welcomeMessage,
            isUser: false,
          ),
        );
        // Add welcome message to conversation history
        _updateConversationHistory("AI", welcomeMessage);
      });
    }

    // Mark initial messages as done loading - now auto-scroll can work for user messages
    setState(() {
      _isLoadingInitialMessages = false;
    });
  }

  void _handleSubmitted(String text) async {
    _textController.clear();

    if (text.trim().isEmpty) return;

    // Check if user is near the bottom before adding message
    final bool wasNearBottom = _isNearBottom();

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );
      _isLoading = true;
      // Add user message to conversation history
      _updateConversationHistory("User", text);
    });

    // Only auto-scroll if user was already near the bottom AND initial messages are done loading
    // This prevents auto-scrolling during initial message loading
    if (wasNearBottom && !_isLoadingInitialMessages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    // Create rich context info that includes:
    // 1. Language preference
    // 2. Deficiency diagnosis information
    // 3. Full conversation history
    String contextInfo = "";

    // Add language preference
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final isTagalog = localeProvider.locale.languageCode == 'tl';
    contextInfo = "LANGUAGE PREFERENCE:\n";
    if (isTagalog) {
      contextInfo +=
          "User prefers TAGALOG/FILIPINO responses. ALL responses must be in Tagalog. Do not mix English.\n\n";
    } else {
      contextInfo += "User prefers ENGLISH responses.\n\n";
    }

    // Add deficiency information
    if (_currentAnalysis != null) {
      contextInfo += "DIAGNOSIS INFORMATION:\n"
          "Deficiency: ${_currentAnalysis!.deficiencyType}\n"
          "Confidence: ${(_currentAnalysis!.confidence * 100).toStringAsFixed(1)}%\n"
          "Diagnosis: ${_currentAnalysis!.diagnosis}\n"
          "Treatment: ${_currentAnalysis!.treatment}\n"
          "Prevention: ${_currentAnalysis!.prevention}\n\n";
    } else {
      final offlineService =
          Provider.of<OfflineDeficiencyService>(context, listen: false);
      contextInfo += "DIAGNOSIS INFORMATION:\n"
          "${offlineService.getContextForChat()}"
          "\n\n";
    }

    // Add full conversation history
    contextInfo += "CONVERSATION HISTORY:\n$_conversationHistory";

    debugPrint("Using context: $contextInfo");

    final answer = await _llmService.answerFarmerQuestion(
      _currentAnalysis?.deficiencyType ?? "unknown",
      text,
      context: contextInfo,
    );

    // Check if user is near the bottom before adding response (reuse the variable from earlier)
    final bool stillNearBottom = _isNearBottom();

    setState(() {
      _messages.add(
        ChatMessage(
          text: answer,
          isUser: false,
        ),
      );
      _isLoading = false;
      // Add AI response to conversation history
      _updateConversationHistory("AI", answer);
    });

    // Only auto-scroll if user was already near the bottom (reading new messages)
    // This prevents jumping to bottom when user is reading older messages
    // Also ensure initial messages are done loading
    if (stillNearBottom && !_isLoadingInitialMessages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  // Update conversation history with new messages
  void _updateConversationHistory(String speaker, String message) {
    // Don't use setState here as it can cause issues with async operations
    _conversationHistory += "$speaker: $message\n\n";
    debugPrint(
        "Conversation history updated, new length: ${_conversationHistory.length}");
  }

  // Check if user is near the bottom of the chat (within 50 pixels - stricter check)
  bool _isNearBottom() {
    if (!_scrollController.hasClients)
      return false; // Don't auto-scroll if controller not ready
    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    // Consider "near bottom" only if within 50 pixels of the bottom (stricter)
    // This ensures user is actually at the bottom, not just "close"
    return (maxScroll - currentScroll) < 50;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Update LLM service locale
    _llmService.currentLocale = localeProvider.locale;

    // Generate title based on language
    final String title;
    if (localeProvider.locale.languageCode == 'tl') {
      title = 'Tagapayo sa ${_currentAnalysis?.deficiencyType ?? "Hindi Alam"}';
    } else {
      title = '${_currentAnalysis?.deficiencyType ?? "Unknown"} Assistant';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          FarmerLanguageSelector(
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            textColor: Colors.white,
            onLanguageChanged: (languageCode) {
              // Update LLM service locale
              _llmService.currentLocale = Locale(languageCode, '');

              // Reset conversation and start over in new language
              setState(() {
                _messages.clear();
                _conversationHistory = "";
              });
              _addInitialMessages();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessage(message);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildThinkingIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
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

  Widget _buildInputArea() {
    final isTagalog = _llmService.currentLocale?.languageCode == 'tl';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: isTagalog ? 'Magtanong...' : 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              onSubmitted: _isLoading ? null : _handleSubmitted,
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: _isLoading
                ? null
                : () => _handleSubmitted(_textController.text),
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    final localeProvider = Provider.of<LocaleProvider>(context);
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
