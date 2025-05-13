import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/leaf_analysis_result.dart';
import '../widgets/custom_button.dart';
import '../models/chat_message.dart';
import '../services/chat_history_service.dart';
import '../services/llm_service.dart';
import '../services/nutrient_deficiency_service.dart';
import '../main.dart';
import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultScreen extends StatefulWidget {
  final LeafAnalysisResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final LLMService _llmService = LLMService();
  final NutrientDeficiencyService _deficiencyService =
      NutrientDeficiencyService();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Update LLMService with current locale
    _llmService.currentLocale = localeProvider.locale;

    // Update NutrientDeficiencyService with current locale
    _deficiencyService.currentLocale = localeProvider.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.analysisComplete),
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
                // Force refresh UI
                setState(() {});
              } else if (value == 'tl') {
                localeProvider.setLocale(const Locale('tl', ''));
                // Update language preference
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('selected_language', 'tl');
                // Update LLMService locale
                _llmService.currentLocale = const Locale('tl', '');
                // Force refresh UI
                setState(() {});
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
            ],
            icon: const Icon(Icons.language),
            tooltip: localizations.selectLanguage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Icon(
              Icons.health_and_safety,
              size: 60,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.analysisComplete,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildResultSection(
              title: localizations.diagnosis,
              content: widget.result.diagnosis,
              icon: Icons.medical_information,
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),
            _buildResultSection(
              title: localizations.recommendedTreatment,
              content: widget.result.treatment,
              icon: Icons.healing,
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 16),
            _buildResultSection(
              title: localizations.preventionTips,
              content: widget.result.prevention,
              icon: Icons.shield,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: localizations.continueToChatAssistant,
              onPressed: () async {
                final chatService =
                    Provider.of<ChatHistoryService>(context, listen: false);

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );

                // Clear any existing chat and set the current deficiency
                chatService.clearMessages();
                chatService.setDeficiency(widget.result.deficiencyType);

                // Add initial message from assistant
                final welcomeMessage = ChatMessage(
                  text:
                      'I can help answer your questions about ${widget.result.deficiencyType} deficiency in your banana plants. What would you like to know?',
                  isUser: false,
                );
                chatService.addMessage(welcomeMessage);

                try {
                  // Get explanation from LLM
                  final explanation =
                      await _llmService.getDeficiencyExplanation(
                          widget.result.deficiencyType,
                          widget.result.confidence);

                  // Add explanation message
                  final explanationMessage = ChatMessage(
                    text: explanation,
                    isUser: false,
                  );
                  chatService.addMessage(explanationMessage);

                  // Get treatment recommendation
                  final treatment = await _llmService
                      .getTreatmentRecommendation(widget.result.deficiencyType);

                  // Add treatment message
                  final treatmentMessage = ChatMessage(
                    text: treatment,
                    isUser: false,
                  );
                  chatService.addMessage(treatmentMessage);
                } catch (e) {
                  // If there's an error, at least add a basic message
                  final errorMessage = ChatMessage(
                    text:
                        'I detected a ${widget.result.deficiencyType} deficiency in your banana plant. I can answer questions about this condition.',
                    isUser: false,
                  );
                  chatService.addMessage(errorMessage);
                }

                // Close loading dialog
                Navigator.of(context).pop();

                // Navigate back to main screen and select the chat tab
                Navigator.of(context).popUntil((route) => route.isFirst);

                // Wait a moment to ensure we're back at the main screen
                Future.microtask(() {
                  // Find and use the MainNavigationScreenState to switch tabs
                  // This approach avoids GlobalKey issues
                  final navigatorState = Navigator.of(context);
                  navigatorState.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) {
                        final mainScreen = const MainNavigationScreen();
                        Future.microtask(() {
                          // Use the static method to navigate to chat tab
                          MainNavigationScreenState.navigateToChatTab();
                        });
                        return mainScreen;
                      },
                    ),
                  );
                });
              },
              icon: Icons.chat,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: localizations.newAnalysis,
              onPressed: () => Navigator.pop(context),
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
