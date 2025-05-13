import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/leaf_analysis_result.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyBuAJh_jiXD8643ZjIbPoSNTNMBVRrM3pM';
  static const String apiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  Future<LeafAnalysisResult> analyzeLeafCondition({
    String? description,
    Locale? locale,
  }) async {
    final isTagalog = locale?.languageCode == 'tl';

    String prompt = isTagalog
        ? '''
Ikaw ay isang propesyonal na dalubhasa sa halamang saging na nagbibigay ng impormasyon sa magsasaka. Sumagot sa isang direkta at malinaw na paraan.

HUWAG gumamit ng mga header o section titles tulad ng "Diagnosis:", "Paggamot:", "Pag-iwas:" o anumang katulad. 

Sumagot lamang batay sa kaalaman na nasa iyo, at huwag kang humingi ng karagdagang impormasyon, larawan, o iba pang detalye. Kung may kulang sa ibinigay na impormasyon, gumawa ng makatuwirang pagpapalagay.

Ang iyong sagot ay dapat maging direkta at impormatibo. Huwag gumamit ng mga bullet points, numbering, o anumang pormal na format.

Tanong ng magsasaka: $description
'''
        : '''
You are a professional banana plant expert providing information to a farmer. Respond in a straightforward, clear manner.

DO NOT use headers or section titles like "Diagnosis:", "Treatment:", "Prevention:" or anything similar. 

Only respond based on the information given to you and DO NOT ask for additional information, pictures, or further details. If information is lacking, make reasonable assumptions.

Your response should be direct and informative. Do not use bullet points, numbering, or any formal formatting.

Farmer's query: $description
''';

    try {
      print('Making API call to: $apiUrl');

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.9,
            'maxOutputTokens': 1024,
          }
        }),
      );

      print('API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print(
            'API Response Body First 200 chars: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

        final jsonResponse = jsonDecode(response.body);
        final candidates = jsonResponse['candidates'];

        if (candidates == null || candidates.isEmpty) {
          throw Exception('No response from AI model');
        }

        final content = candidates[0]['content'];

        if (content == null ||
            content['parts'] == null ||
            content['parts'].isEmpty) {
          throw Exception('Invalid response format');
        }

        final generatedText = content['parts'][0]['text'];

        if (generatedText == null || generatedText.isEmpty) {
          throw Exception('Empty response from AI model');
        }

        // For a more straightforward app, we'll put everything in the diagnosis field
        // and leave the other fields empty
        return LeafAnalysisResult(
          diagnosis: generatedText.trim(),
          treatment: '',
          prevention: '',
        );
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      throw Exception('Failed to analyze leaf condition: $e');
    }
  }
}
