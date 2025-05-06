import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/nutrient_deficiency_service.dart';
import '../models/leaf_analysis_result.dart';
import 'result_screen.dart';

class DeficiencyDetectionScreen extends StatefulWidget {
  const DeficiencyDetectionScreen({Key? key}) : super(key: key);

  @override
  State<DeficiencyDetectionScreen> createState() =>
      _DeficiencyDetectionScreenState();
}

class _DeficiencyDetectionScreenState extends State<DeficiencyDetectionScreen> {
  final NutrientDeficiencyService _deficiencyService =
      NutrientDeficiencyService();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isApiAvailable = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkApiStatus();
  }

  Future<void> _checkApiStatus() async {
    try {
      final isAvailable = await _deficiencyService.isApiAvailable();
      setState(() {
        _isApiAvailable = isAvailable;
        if (!isAvailable) {
          _errorMessage =
              'The AI model server is not available. Make sure it\'s running at localhost:5000';
        }
      });
    } catch (e) {
      setState(() {
        _isApiAvailable = false;
        _errorMessage = 'Failed to connect to AI server: $e';
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _deficiencyService.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }

    if (!_isApiAvailable) {
      setState(() {
        _errorMessage =
            'The AI model server is not available. Make sure it\'s running at localhost:5000';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _deficiencyService.analyzeImage(_selectedImage!);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navigate to results screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error analyzing image: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrient Deficiency Detection'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Status indicator
            if (!_isApiAvailable)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'AI model server not available. Make sure Python server is running.',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.red.shade700),
                      onPressed: _checkApiStatus,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Image preview
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Select a banana leaf image',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Image selection buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Analyze button
            ElevatedButton(
              onPressed:
                  _isLoading || _selectedImage == null ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Analyzing...'),
                      ],
                    )
                  : const Text(
                      'Analyze Leaf',
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
