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
      'welcomeMessage':
          'Ask me any questions about banana leaf deficiencies and diseases. I\'m here to help!',
      'messageHint': 'Describe leaf condition or ask a question...',
      'send': 'Send',
      'treatment': 'Treatment:',
      'prevention': 'Prevention:',
      'errorMessage': 'Sorry, I encountered an error. Please try again.',
      'detect': 'Detect',
      'chat': 'Chat',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'analyzing': 'Analyzing leaf...',
      'selectImage': 'Select a banana leaf image',
      'deficiencyDetection': 'Nutrient Deficiency Detection',
      'serverNotAvailable':
          'AI model server not available. Make sure Python server is running.',
      'refresh': 'Refresh',
      'takePhoto': 'Take Photo',
      'uploadImage': 'Upload Image',
      'analysisComplete': 'Leaf Analysis Complete',
      'diagnosis': 'Diagnosis',
      'recommendedTreatment': 'Recommended Treatment',
      'preventionTips': 'Prevention Tips',
      'continueToChatAssistant': 'Continue to Chat Assistant',
      'newAnalysis': 'New Analysis',
      'welcomeToBananaDoc': 'Welcome to BananaDoc',
      'selectLanguage': 'Please select your preferred language',
      'english': 'English',
      'filipino': 'Filipino (Tagalog)',
      'clearChatHistory': 'Clear Chat History',
      'analyze': 'Analyze Leaf',
      'photographyTips': 'Photography Tips',
      'tip1GoodLighting': 'Take photos in good natural lighting',
      'tip2CloseUp': 'Get close-up shots of affected leaves',
      'tip3ClearFocus': 'Make sure the image is clear and in focus',
      'selectedImage': 'Selected Image',
      'retake': 'Retake',
    },
    'tl': {
      'appTitle': 'BananaDoc',
      'consultant': 'BananaDoc Consultant',
      'welcomeMessage':
          'Magtanong tungkol sa mga kakulangan at sakit ng dahon ng saging. Handa akong tumulong!',
      'messageHint': 'Ilarawan ang kondisyon ng dahon o magtanong...',
      'send': 'Ipadala',
      'treatment': 'Paggamot:',
      'prevention': 'Pag-iwas:',
      'errorMessage': 'Paumanhin, may naganap na error. Subukan muli.',
      'detect': 'Suriin',
      'chat': 'Usapan',
      'camera': 'Kamera',
      'gallery': 'Galeri',
      'analyzing': 'Sinusuri ang dahon...',
      'selectImage': 'Pumili ng larawan ng dahon ng saging',
      'deficiencyDetection': 'Pagsusuri ng Kakulangan sa Sustansya',
      'serverNotAvailable':
          'Hindi available ang AI model server. Siguraduhing tumatakbo ang Python server.',
      'refresh': 'I-refresh',
      'takePhoto': 'Kumuha ng Larawan',
      'uploadImage': 'Mag-upload ng Larawan',
      'analysisComplete': 'Kompleto na ang Pagsusuri ng Dahon',
      'diagnosis': 'Diagnosis',
      'recommendedTreatment': 'Inirerekumendang Paggamot',
      'preventionTips': 'Mga Tip sa Pag-iwas',
      'continueToChatAssistant': 'Magpatuloy sa Chat Assistant',
      'newAnalysis': 'Bagong Pagsusuri',
      'welcomeToBananaDoc': 'Maligayang Pagdating sa BananaDoc',
      'selectLanguage': 'Piliin ang iyong gustong wika',
      'english': 'Ingles',
      'filipino': 'Filipino (Tagalog)',
      'clearChatHistory': 'Burahin ang Kasaysayan ng Chat',
      'analyze': 'Suriin ang Dahon',
      'photographyTips': 'Mga Tip sa Pagkuha ng Larawan',
      'tip1GoodLighting': 'Kumuha ng larawan sa magandang natural na liwanag',
      'tip2CloseUp': 'Kumuha ng malapit na larawan ng mga apektadong dahon',
      'tip3ClearFocus': 'Siguraduhing malinaw at naka-focus ang larawan',
      'selectedImage': 'Napiling Larawan',
      'retake': 'Ulitin',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get consultant =>
      _localizedValues[locale.languageCode]!['consultant']!;
  String get welcomeMessage =>
      _localizedValues[locale.languageCode]!['welcomeMessage']!;
  String get messageHint =>
      _localizedValues[locale.languageCode]!['messageHint']!;
  String get send => _localizedValues[locale.languageCode]!['send']!;
  String get treatment => _localizedValues[locale.languageCode]!['treatment']!;
  String get prevention =>
      _localizedValues[locale.languageCode]!['prevention']!;
  String get errorMessage =>
      _localizedValues[locale.languageCode]!['errorMessage']!;
  String get detect => _localizedValues[locale.languageCode]!['detect']!;
  String get chat => _localizedValues[locale.languageCode]!['chat']!;
  String get camera => _localizedValues[locale.languageCode]!['camera']!;
  String get gallery => _localizedValues[locale.languageCode]!['gallery']!;
  String get analyzing => _localizedValues[locale.languageCode]!['analyzing']!;
  String get selectImage =>
      _localizedValues[locale.languageCode]!['selectImage']!;
  String get deficiencyDetection =>
      _localizedValues[locale.languageCode]!['deficiencyDetection']!;
  String get serverNotAvailable =>
      _localizedValues[locale.languageCode]!['serverNotAvailable']!;
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['takePhoto']!;
  String get uploadImage =>
      _localizedValues[locale.languageCode]!['uploadImage']!;
  String get analysisComplete =>
      _localizedValues[locale.languageCode]!['analysisComplete']!;
  String get diagnosis => _localizedValues[locale.languageCode]!['diagnosis']!;
  String get recommendedTreatment =>
      _localizedValues[locale.languageCode]!['recommendedTreatment']!;
  String get preventionTips =>
      _localizedValues[locale.languageCode]!['preventionTips']!;
  String get continueToChatAssistant =>
      _localizedValues[locale.languageCode]!['continueToChatAssistant']!;
  String get newAnalysis =>
      _localizedValues[locale.languageCode]!['newAnalysis']!;
  String get welcomeToBananaDoc =>
      _localizedValues[locale.languageCode]!['welcomeToBananaDoc']!;
  String get selectLanguage =>
      _localizedValues[locale.languageCode]!['selectLanguage']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get filipino => _localizedValues[locale.languageCode]!['filipino']!;
  String get clearChatHistory =>
      _localizedValues[locale.languageCode]!['clearChatHistory']!;
  String get analyze => _localizedValues[locale.languageCode]!['analyze']!;
  String get photographyTips =>
      _localizedValues[locale.languageCode]!['photographyTips']!;
  String get tip1GoodLighting =>
      _localizedValues[locale.languageCode]!['tip1GoodLighting']!;
  String get tip2CloseUp =>
      _localizedValues[locale.languageCode]!['tip2CloseUp']!;
  String get tip3ClearFocus =>
      _localizedValues[locale.languageCode]!['tip3ClearFocus']!;
  String get selectedImage =>
      _localizedValues[locale.languageCode]!['selectedImage']!;
  String get retake => _localizedValues[locale.languageCode]!['retake']!;
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
