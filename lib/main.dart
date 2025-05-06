import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/deficiency_detection_screen.dart';
import 'localization/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'services/chat_history_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/llm_service.dart';
import 'services/nutrient_deficiency_service.dart';

// Remove global key - it's causing duplication issues
// Use a navigation service singleton instead

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ChatHistoryService()),
      ],
      child: const BananaDocApp(),
    ),
  );
}

class BananaDocApp extends StatelessWidget {
  const BananaDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'BananaDoc',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('tl', ''),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFFFFEB3B),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSelectedLanguage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while checking preferences
          return const Center(child: CircularProgressIndicator());
        }

        // Show the selection screen only if the user hasn't chosen a language yet
        if (snapshot.hasData && snapshot.data == true) {
          // User has already selected a language, go directly to the main screen
          return const MainNavigationScreen();
        }

        // Otherwise, show language selection
        return const LanguageSelectionScreen();
      },
    );
  }

  Future<bool> _hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('selected_language');
  }
}

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
  }

  @override
  Widget build(BuildContext context) {
    // Get localizations - we may not have the user's preferred language yet,
    // but we'll use whatever locale is currently active
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.language,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.welcomeToBananaDoc,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${localizations.selectLanguage} / Piliin ang iyong gustong wika',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildLanguageButton(
                context,
                localizations.english,
                'en',
                Icons.flag,
              ),
              const SizedBox(height: 16),
              _buildLanguageButton(
                context,
                localizations.filipino,
                'tl',
                Icons.flag,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
      BuildContext context, String label, String languageCode, IconData icon) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () async {
        final localeProvider =
            Provider.of<LocaleProvider>(context, listen: false);
        localeProvider.setLocale(Locale(languageCode, ''));

        // Save language preference
        await _saveLanguagePreference(languageCode);

        // Navigate to main screen
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

// Create a singleton to manage the current tab index
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  int currentIndex = 0;
  final List<Function(int)> _listeners = [];

  void setCurrentIndex(int index) {
    currentIndex = index;
    // Notify all listeners about the tab change
    for (var listener in _listeners) {
      listener(index);
    }
  }

  void addListener(Function(int) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(int) listener) {
    _listeners.remove(listener);
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => MainNavigationScreenState();
}

class MainNavigationScreenState extends State<MainNavigationScreen> {
  // Use the navigation service instead of a local state
  final NavigationService _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    // Listen for tab change requests from the service
    _navigationService.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    _navigationService.removeListener(_handleTabChange);
    super.dispose();
  }

  // Handle tab change requests
  void _handleTabChange(int index) {
    setState(() {
      // Update UI when tab change is requested
    });
  }

  // User tapped on a tab
  void _onItemTapped(int index) {
    _navigationService.setCurrentIndex(index);
  }

  // Public method to navigate to chat tab, can be called from anywhere
  static void navigateToChatTab() {
    NavigationService().setCurrentIndex(1);
  }

  static const List<Widget> _screens = [
    DeficiencyDetectionScreen(),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Create an instance of LLMService and update its locale
    final llmService = LLMService();
    llmService.currentLocale = localeProvider.locale;

    // Create an instance of NutrientDeficiencyService and update its locale
    final deficiencyService = NutrientDeficiencyService();
    deficiencyService.currentLocale = localeProvider.locale;

    return Scaffold(
      appBar: _navigationService.currentIndex == 1
          ? null
          : AppBar(
              title: Text(localizations.appTitle),
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
                    } else if (value == 'tl') {
                      localeProvider.setLocale(const Locale('tl', ''));
                      // Update language preference
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('selected_language', 'tl');
                    } else if (value == 'language_selection') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionScreen(),
                        ),
                      );
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
      body: _screens[_navigationService.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            label: localizations.detect,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: localizations.chat,
          ),
        ],
        currentIndex: _navigationService.currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
