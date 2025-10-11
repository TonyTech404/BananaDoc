import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/leaf_analysis_result.dart';

class NutrientDeficiencyService {
  // URLs for different platforms
  static const String _baseUrlMobile = 'http://localhost:5002';
  static const String _baseUrlWeb =
      'http://127.0.0.1:5002'; // Use IP instead of localhost for web

  // Get appropriate URL based on platform
  static String get baseUrl => kIsWeb ? _baseUrlWeb : _baseUrlMobile;
  static String get apiUrl => '$baseUrl/predict';
  static String get healthUrl => '$baseUrl/health';

  // Track current locale
  Locale? currentLocale;

  // Method to check if the API is available
  Future<bool> isApiAvailable() async {
    try {
      print('Checking API at $healthUrl');
      final response = await http
          .get(
            Uri.parse(healthUrl),
          )
          .timeout(const Duration(seconds: 5));

      print('API response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('API not available: $e');
      return false;
    }
  }

  // Method to analyze image and detect nutrient deficiency (for mobile)
  Future<LeafAnalysisResult> analyzeImage(File imageFile) async {
    try {
      // Read file as bytes
      List<int> imageBytes = await imageFile.readAsBytes();

      // Convert to base64
      String base64Image = base64Encode(imageBytes);

      return _sendAnalysisRequest(base64Image);
    } catch (e) {
      print('Error in NutrientDeficiencyService: $e');
      throw Exception('Failed to analyze image: $e');
    }
  }

  // Method to analyze image for web
  Future<LeafAnalysisResult> analyzeImageWeb(Uint8List imageBytes) async {
    try {
      // Convert to base64
      String base64Image = base64Encode(imageBytes);

      return _sendAnalysisRequest(base64Image);
    } catch (e) {
      print('Error in NutrientDeficiencyService (web): $e');
      throw Exception('Failed to analyze image: $e');
    }
  }

  // Common method to send API request
  Future<LeafAnalysisResult> _sendAnalysisRequest(String base64Image) async {
    // Make API request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'image': base64Image,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // Check if Filipino is the current language
      bool isFilipino = currentLocale?.languageCode == 'tl';

      String treatment = jsonResponse['treatment'] ?? '';
      String prevention = jsonResponse['prevention'] ?? '';

      // Translate treatment and prevention if in Filipino
      if (isFilipino) {
        treatment = _translateTreatment(jsonResponse['deficiency'], treatment);
        prevention =
            _translatePrevention(jsonResponse['deficiency'], prevention);
      }

      // Create analysis result from API response
      return LeafAnalysisResult(
        diagnosis: _formatDiagnosis(jsonResponse['deficiency'],
            jsonResponse['confidence'], jsonResponse['symptoms']),
        treatment: treatment,
        prevention: prevention,
        deficiencyType: jsonResponse['deficiency'] ?? '',
        confidence: jsonResponse['confidence'] ?? 0.0,
      );
    } else {
      throw Exception(
          'API Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  // Helper to translate treatment text
  String _translateTreatment(String deficiency, String englishTreatment) {
    // Simple mapping for common treatments
    final Map<String, String> treatmentTranslations = {
      'Sulphur':
          'Maglagay ng elemental sulfur, ammonium sulfate, o gypsum. Ang foliar spray ay hindi gaanong epektibo para sa sulfur.',
      'Potassium':
          'Maglagay ng potassium sulphate, potassium chloride, o foliar spray na may potassium nitrate.',
      'Magnesium':
          'Maglagay ng magnesium sulphate (Epsom salt) o dolomitic limestone. Gamitin ang foliar spray na may 2% magnesium sulphate.',
      'Boron':
          'Maglagay ng borax o iba pang boron fertilizers. Mag-spray ng 0.1% hanggang 0.25% na solusyon ng borax.',
      'Calcium':
          'Maglagay ng calcium nitrate, calcium sulfate (gypsum) o apog. Mag-spray ng calcium chloride.',
      'Iron':
          'Maglagay ng iron sulfate o chelated iron. Maglagay ng organic matter sa lupa.',
      'Manganese':
          'Maglagay ng manganese sulfate o manganese chelates. Mag-spray ng 0.1% manganese sulfate.',
      'Zinc':
          'Maglagay ng zinc sulfate o zinc chelates. Mag-spray ng 0.2% zinc sulfate.',
      'Healthy':
          'Ipagpatuloy ang balanced na fertilization at wastong pangangalaga.',
    };

    return treatmentTranslations[deficiency] ?? englishTreatment;
  }

  // Helper to translate prevention text
  String _translatePrevention(String deficiency, String englishPrevention) {
    // Simple mapping for common preventions
    final Map<String, String> preventionTranslations = {
      'Sulphur':
          'Gumamit ng mga pataba na may sulfur paminsan-minsan, magdagdag ng organic matter sa lupa.',
      'Potassium':
          'Regular na pagsusuri ng lupa, paggamit ng mga pataba na may potassium, wastong sukat ng patubig.',
      'Magnesium':
          'Panatilihin ang tamang pH ng lupa, iwasan ang sobrang paggamit ng potassium at calcium.',
      'Boron':
          'Regular na pagsusuri ng lupa, pagpapanatili ng tamang pH ng lupa, at pagdagdag ng organic matter sa lupa.',
      'Calcium':
          'Panatilihin ang tamang pH ng lupa, iwasan ang sobrang potassium na pataba, tiyakin ang wastong patubig.',
      'Iron':
          'Panatilihin ang pH ng lupa sa 5.5 hanggang 6.5, magdagdag ng organic matter, iwasan ang sobrang patubig.',
      'Manganese':
          'Panatilihin ang pH ng lupa sa mas mababa sa 7.0, regular na pagsusuri ng lupa.',
      'Zinc':
          'Regular na pagsusuri ng lupa, gumamit ng mga pataba na may zinc, magdagdag ng organic matter.',
      'Healthy':
          'Regular na pagsusuri ng lupa, balanseng pagpataba, at wastong gawain sa pagdidilig.',
    };

    return preventionTranslations[deficiency] ?? englishPrevention;
  }

  // Helper method to format diagnosis text
  String _formatDiagnosis(
      String deficiency, double confidence, String symptoms) {
    final confidencePercent = (confidence * 100).toStringAsFixed(1);

    // Check if Filipino is the current language
    bool isFilipino = currentLocale?.languageCode == 'tl';

    if (isFilipino) {
      return 'Ang dahon ng saging na ito ay nagpapakita ng palatandaan ng kakulangan sa $deficiency '
          '(${confidencePercent}% kumpiyansa).\n\n'
          'Mga sintomas: $symptoms';
    } else {
      return 'This banana leaf shows signs of $deficiency deficiency '
          '(${confidencePercent}% confidence).\n\n'
          'Symptoms: $symptoms';
    }
  }

  // Method to pick image from gallery or camera
  Future<dynamic> pickImage({required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, return the bytes directly
          return await pickedFile.readAsBytes();
        } else {
          // For mobile, return a File
          return File(pickedFile.path);
        }
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      throw Exception('Failed to pick image: $e');
    }
  }
}
