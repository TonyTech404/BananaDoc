import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/llm_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  final String deficiencyType;
  final double confidence;

  const ChatScreen(
      {Key? key, required this.deficiencyType, required this.confidence})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final LLMService _llmService = LLMService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addInitialMessages();
  }

  void _addInitialMessages() async {
    // Add welcome message
    setState(() {
      _messages.add(
        ChatMessage(
          text:
              'I can help answer your questions about ${widget.deficiencyType} deficiency in your banana plants. What would you like to know?',
          isUser: false,
        ),
      );
    });

    // Add detailed explanation
    setState(() {
      _isLoading = true;
    });

    final explanation = await _llmService.getDeficiencyExplanation(
        widget.deficiencyType, widget.confidence);

    setState(() {
      _messages.add(
        ChatMessage(
          text: explanation,
          isUser: false,
        ),
      );
      _isLoading = false;
    });

    // Add treatment recommendation
    setState(() {
      _isLoading = true;
    });

    final treatment =
        await _llmService.getTreatmentRecommendation(widget.deficiencyType);

    setState(() {
      _messages.add(
        ChatMessage(
          text: treatment,
          isUser: false,
        ),
      );
      _isLoading = false;
    });
  }

  void _handleSubmitted(String text) async {
    _textController.clear();

    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );
      _isLoading = true;
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    // Get answer from LLM
    final answer =
        await _llmService.answerFarmerQuestion(widget.deficiencyType, text);

    setState(() {
      _messages.add(
        ChatMessage(
          text: answer,
          isUser: false,
        ),
      );
      _isLoading = false;
    });

    // Scroll to bottom again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deficiencyType} Assistant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
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
              ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
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
                    color: Colors.black.withOpacity(0.8),
                  ),
                  h1: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  h2: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  h3: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  listBullet: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
