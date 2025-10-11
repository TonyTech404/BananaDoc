class AppConfig {
  // DO NOT commit actual API keys to version control
  // These should be set through build arguments or environment in production
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '', // Empty default - will fail if not provided
  );
  
  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';
  
  // Validate configuration
  static bool get isValid => geminiApiKey.isNotEmpty;
  
  static void validateConfig() {
    if (!isValid) {
      throw Exception(
        'GEMINI_API_KEY is required. '
        'Set it via --dart-define=GEMINI_API_KEY=your_key '
        'or environment variables during build.',
      );
    }
  }
}