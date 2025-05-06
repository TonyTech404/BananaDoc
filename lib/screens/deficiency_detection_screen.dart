import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/nutrient_deficiency_service.dart';
import 'result_screen.dart';
import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';

class DeficiencyDetectionScreen extends StatefulWidget {
  const DeficiencyDetectionScreen({Key? key}) : super(key: key);

  @override
  State<DeficiencyDetectionScreen> createState() =>
      _DeficiencyDetectionScreenState();
}

class _DeficiencyDetectionScreenState extends State<DeficiencyDetectionScreen> {
  final NutrientDeficiencyService _deficiencyService =
      NutrientDeficiencyService();
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  bool _isApiAvailable = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkApiStatus();

    // Set initial locale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localeProvider =
          Provider.of<LocaleProvider>(context, listen: false);
      _deficiencyService.currentLocale = localeProvider.locale;
    });
  }

  Future<void> _checkApiStatus() async {
    try {
      final isAvailable = await _deficiencyService.isApiAvailable();
      setState(() {
        _isApiAvailable = isAvailable;
        if (!isAvailable) {
          _errorMessage =
              'The AI model server is not available. Make sure it\'s running at ${NutrientDeficiencyService.baseUrl}';
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
      final pickedImage = await _deficiencyService.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          if (kIsWeb) {
            _selectedImageBytes = pickedImage;
            _selectedImageFile = null;
          } else {
            _selectedImageFile = pickedImage as File;
            _selectedImageBytes = null;
          }
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
    final localizations = AppLocalizations.of(context);

    if ((_selectedImageFile == null && _selectedImageBytes == null) ||
        (kIsWeb && _selectedImageBytes == null) ||
        (!kIsWeb && _selectedImageFile == null)) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }

    if (!_isApiAvailable) {
      setState(() {
        _errorMessage = localizations.serverNotAvailable;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = kIsWeb
          ? await _deficiencyService.analyzeImageWeb(_selectedImageBytes!)
          : await _deficiencyService.analyzeImage(_selectedImageFile!);

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
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    // Update the NutrientDeficiencyService locale when it changes
    _deficiencyService.currentLocale = localeProvider.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.deficiencyDetection),
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
                        localizations.serverNotAvailable,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.red.shade700),
                      onPressed: _checkApiStatus,
                      tooltip: localizations.refresh,
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
              child: _hasSelectedImage()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _displaySelectedImage(),
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
                            localizations.selectImage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // Image source buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(localizations.takePhoto),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(localizations.uploadImage),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Analyze button
            ElevatedButton(
              onPressed: _isLoading ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(localizations.analyzing),
                      ],
                    )
                  : const Text(
                      'Analyze Leaf',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasSelectedImage() {
    return (kIsWeb && _selectedImageBytes != null) ||
        (!kIsWeb && _selectedImageFile != null);
  }

  Widget _displaySelectedImage() {
    if (kIsWeb && _selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (!kIsWeb && _selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    return Container(); // Fallback
  }
}
