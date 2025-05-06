import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = {
    'en': {
      'appTitle': 'BananaDoc',
      'consultant': 'BananaDoc Consultant',
      'welcomeMessage': 'Ask me any questions about banana leaf deficiencies and diseases. I\'m here to help!',
      'messageHint': 'Describe leaf condition or ask a question...',
      'send': 'Send',
      'treatment': 'Treatment:',
      'prevention': 'Prevention:',
      'errorMessage': 'Sorry, I encountered an error. Please try again.',
    },
    'tl': {
      'appTitle': 'BananaDoc',
      'consultant': 'BananaDoc Consultant',
      'welcomeMessage': 'Magtanong tungkol sa mga kakulangan at sakit ng dahon ng saging. Handa akong tumulong!',
      'messageHint': 'Ilarawan ang kondisyon ng dahon o magtanong...',
      'send': 'Ipadala',
      'treatment': 'Paggamot:',
      'prevention': 'Pag-iwas:',
      'errorMessage': 'Paumanhin, may naganap na error. Subukan muli.',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get consultant => _localizedValues[locale.languageCode]!['consultant']!;
  String get welcomeMessage => _localizedValues[locale.languageCode]!['welcomeMessage']!;
  String get messageHint => _localizedValues[locale.languageCode]!['messageHint']!;
  String get send => _localizedValues[locale.languageCode]!['send']!;
  String get treatment => _localizedValues[locale.languageCode]!['treatment']!;
  String get prevention => _localizedValues[locale.languageCode]!['prevention']!;
  String get errorMessage => _localizedValues[locale.languageCode]!['errorMessage']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tl'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
} 