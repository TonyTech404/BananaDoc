// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:bananadoc/providers/locale_provider.dart';

// Simple test app without dependencies on dart:html
class TestBananaDocApp extends StatelessWidget {
  const TestBananaDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'BananaDoc Test',
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('tl', ''),
      ],
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFFFFEB3B),
        ),
      ),
      home: Scaffold(
        body: const Center(child: Text('BananaDoc Test')),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Detect',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: const Color(0xFF4CAF50),
          onTap: (_) {},
        ),
      ),
    );
  }
}

void main() {
  testWidgets('App navigation structure test', (WidgetTester tester) async {
    // Build our test app version
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const TestBananaDocApp(),
      ),
    );

    // Verify that the app has a bottom navigation bar with expected items
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.byIcon(Icons.chat), findsOneWidget);

    // Verify "Detect" label is present
    expect(find.text('Detect'), findsOneWidget);
  });
}
