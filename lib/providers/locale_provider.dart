import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', '');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'tl'].contains(locale.languageCode)) return;
    
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('tl', '');
    } else {
      _locale = const Locale('en', '');
    }
    notifyListeners();
  }
} 