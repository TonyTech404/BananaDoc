import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/leaf_analysis_result.dart';

class NutrientDeficiencyService {
  // Change this URL to match your API server
  static const String apiUrl = 'http://localhost:5000/predict';

  // Method to check if the API is available
  Future<bool> isApiAvailable() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://localhost:5000/health'),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('API not available: $e');
      return false;
    }
  }

  // Method to analyze image and detect nutrient deficiency
  Future<LeafAnalysisResult> analyzeImage(File imageFile) async {
    try {
      // Read file as bytes
      List<int> imageBytes = await imageFile.readAsBytes();

      // Convert to base64
      String base64Image = base64Encode(imageBytes);

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

        // Create analysis result from API response
        return LeafAnalysisResult(
          diagnosis: _formatDiagnosis(jsonResponse['deficiency'],
              jsonResponse['confidence'], jsonResponse['symptoms']),
          treatment: jsonResponse['treatment'] ?? '',
          prevention: jsonResponse['prevention'] ?? '',
        );
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error in NutrientDeficiencyService: $e');
      throw Exception('Failed to analyze image: $e');
    }
  }

  // Helper method to format diagnosis text
  String _formatDiagnosis(
      String deficiency, double confidence, String symptoms) {
    final confidencePercent = (confidence * 100).toStringAsFixed(1);

    return 'This banana leaf shows signs of $deficiency deficiency '
        '(${confidencePercent}% confidence).\n\n'
        'Symptoms: $symptoms';
  }

  // Method to pick image from gallery or camera
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      throw Exception('Failed to pick image: $e');
    }
  }
}
