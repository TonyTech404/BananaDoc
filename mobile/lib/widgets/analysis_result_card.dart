import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/leaf_analysis_result.dart';
import '../screens/chat_screen.dart';
import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';

class AnalysisResultCard extends StatefulWidget {
  final LeafAnalysisResult result;

  const AnalysisResultCard({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  State<AnalysisResultCard> createState() => _AnalysisResultCardState();
}

class _AnalysisResultCardState extends State<AnalysisResultCard> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: _getDeficiencyColor(widget.result.deficiencyType),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.analysisComplete,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getDeficiencyColor(widget.result.deficiencyType),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildResultSection(
              title: localizations.diagnosis,
              content: widget.result.diagnosis,
              icon: Icons.analytics,
              color: _getDeficiencyColor(widget.result.deficiencyType),
            ),
            const SizedBox(height: 12),
            _buildResultSection(
              title: localizations.recommendedTreatment,
              content: widget.result.treatment,
              icon: Icons.healing,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildResultSection(
              title: localizations.preventionTips,
              content: widget.result.prevention,
              icon: Icons.shield,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            // Chat with AI button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Create customized message based on current locale
                  String initialMessage = localeProvider.locale.languageCode ==
                          'tl'
                      ? "Nasuri ko ang dahon ng iyong saging at natuklasan ang kakulangan sa ${widget.result.deficiencyType}. Magtanong ka tungkol sa pangangasiwa ng problemang ito."
                      : "I've analyzed your banana leaf and detected ${widget.result.deficiencyType} deficiency. Ask me any questions you have about managing this issue.";

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        analysisResult: widget.result,
                        initialMessage: initialMessage,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat),
                label: Text(
                  localizations.continueToChatAssistant,
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Color _getDeficiencyColor(String deficiencyType) {
    switch (deficiencyType.toLowerCase()) {
      case 'healthy':
        return Colors.green;
      case 'nitrogen':
        return Colors.amber.shade700;
      case 'phosphorus':
        return Colors.purple;
      case 'potassium':
        return Colors.orange;
      case 'calcium':
        return Colors.red;
      case 'magnesium':
        return Colors.pink;
      case 'sulphur':
        return Colors.amber;
      case 'iron':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }
}
