class AppConfig {
  // DO NOT commit actual API keys to version control
  // These should be set through build arguments or environment in production

  // Gemini API Configuration
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '', // Empty default - will fail if not provided
  );

  static const String geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  // Backend API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5002',
  );

  // Backend API Key for authentication
  static const String backendApiKey = String.fromEnvironment(
    'BACKEND_API_KEY',
    defaultValue: '', // Empty default - will fail if not provided in production
  );

  // Validate configuration
  static bool get isValid => geminiApiKey.isNotEmpty;

  static bool get isBackendApiKeyValid => backendApiKey.isNotEmpty;

  static void validateConfig() {
    if (!isValid) {
      throw Exception(
        'GEMINI_API_KEY is required. '
        'Set it via --dart-define=GEMINI_API_KEY=your_key '
        'or environment variables during build.',
      );
    }
  }

  static void validateBackendConfig() {
    if (!isBackendApiKeyValid) {
      throw Exception(
        'BACKEND_API_KEY is required for API authentication. '
        'Set it via --dart-define=BACKEND_API_KEY=your_key '
        'or environment variables during build.',
      );
    }
  }
}
