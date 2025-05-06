import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/leaf_analysis_result.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyBuAJh_jiXD8643ZjIbPoSNTNMBVRrM3pM';
  static const String apiUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  Future<LeafAnalysisResult> analyzeLeafCondition({
    String? description,
    Locale? locale,
  }) async {
    final isTagalog = locale?.languageCode == 'tl';
    
    String prompt = isTagalog
        ? '''
Ikaw ay isang magalang at mapagkaibigan na dalubhasa sa halamang saging na nakikipag-usap sa isang magsasaka. Sumagot sa isang natural at conversational na paraan, tulad ng pagsagot ng isang kaibigan.

HUWAG gumamit ng mga header o section titles tulad ng "Diagnosis:", "Paggamot:", "Pag-iwas:" o anumang katulad. 

Sumagot lamang batay sa kaalaman na nasa iyo, at huwag kang humingi ng karagdagang impormasyon, larawan, o iba pang detalye. Kung may kulang sa ibinigay na impormasyon, gumawa ng makatuwirang pagpapalagay.

Ang iyong sagot ay dapat maging tulad ng isang normal na pag-uusap. Huwag gumamit ng mga bullet points, numbering, o anumang pormal na format.

Tanong ng magsasaka: $description
'''
        : '''
You are a friendly and conversational banana plant expert having a casual chat with a farmer. Respond in a natural, conversational way as if you're having a friendly conversation.

DO NOT use headers or section titles like "Diagnosis:", "Treatment:", "Prevention:" or anything similar. 

Only respond based on the information given to you and DO NOT ask for additional information, pictures, or further details. If information is lacking, make reasonable assumptions.

Your response should be like a normal conversation. Do not use bullet points, numbering, or any formal formatting.

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
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      print('API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('API Response Body First 200 chars: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
        
        final jsonResponse = jsonDecode(response.body);
        final candidates = jsonResponse['candidates'];
        
        if (candidates == null || candidates.isEmpty) {
          throw Exception('No response from AI model');
        }
        
        final content = candidates[0]['content'];
        
        if (content == null || content['parts'] == null || content['parts'].isEmpty) {
          throw Exception('Invalid response format');
        }
        
        final generatedText = content['parts'][0]['text'];
        
        if (generatedText == null || generatedText.isEmpty) {
          throw Exception('Empty response from AI model');
        }
        
        // For a more conversational app, we'll put everything in the diagnosis field
        // and leave the other fields empty
        return LeafAnalysisResult(
          diagnosis: generatedText.trim(),
          treatment: '',
          prevention: '',
        );
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      throw Exception('Failed to analyze leaf condition: $e');
    }
  }
} 