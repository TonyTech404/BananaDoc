import 'package:flutter/material.dart';
import '../models/leaf_analysis_result.dart';
import '../widgets/custom_button.dart';

class ResultScreen extends StatelessWidget {
  final LeafAnalysisResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
            const Text(
              'Leaf Analysis Complete',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildResultSection(
              title: 'Diagnosis',
              content: result.diagnosis,
              icon: Icons.medical_information,
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),
            _buildResultSection(
              title: 'Recommended Treatment',
              content: result.treatment,
              icon: Icons.healing,
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 16),
            _buildResultSection(
              title: 'Prevention Tips',
              content: result.prevention,
              icon: Icons.shield,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'New Analysis',
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