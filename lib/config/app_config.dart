import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Read from .env file at runtime
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent';
  
  // Validate configuration
  static bool get isValid => geminiApiKey.isNotEmpty;
  
  static void validateConfig() {
    if (!isValid) {
      throw Exception(
        'GEMINI_API_KEY is required. '
        'Set it in your .env file.',
      );
    }
  }
}