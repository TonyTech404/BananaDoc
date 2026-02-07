import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/nutrient_deficiency_service.dart';
import '../services/offline_deficiency_service.dart';
import '../models/leaf_analysis_result.dart';
import '../widgets/analysis_result_card.dart';
import '../widgets/farmer_image_picker.dart';
import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../services/tflite_service.dart';

class DeficiencyDetectionScreen extends StatefulWidget {
  const DeficiencyDetectionScreen({super.key});

  @override
  State<DeficiencyDetectionScreen> createState() =>
      _DeficiencyDetectionScreenState();
}

class _DeficiencyDetectionScreenState extends State<DeficiencyDetectionScreen> {
  // For non-web platforms
  File? _selectedImageFile;
  // For web platform
  Uint8List? _selectedImageBytes;

  bool _isLoading = false;
  bool _isInitializing = true;
  LeafAnalysisResult? _analysisResult;
  String? _errorMessage;
  final NutrientDeficiencyService _apiService = NutrientDeficiencyService();

  @override
  void initState() {
    super.initState();
    _initializeModelOnStartup();
  }

  Future<void> _initializeModelOnStartup() async {
    setState(() {
      _isInitializing = true;
    });

    final offlineService =
        Provider.of<OfflineDeficiencyService>(context, listen: false);
    final success = await offlineService.ensureModelInitialized();

    setState(() {
      _isInitializing = false;
      if (!success) {
        _errorMessage = offlineService.errorMessage ??
            'Failed to initialize model. Please restart the app.';
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update service locale when app locale changes
    final locale = Localizations.localeOf(context);
    _apiService.currentLocale = locale;

    // Also update TFLite service locale
    final tfliteService = TFLiteService();
    tfliteService.currentLocale = locale;

    // Force refresh UI when language changes
    setState(() {});
  }

  // Check if we have a selected image (either file or bytes)
  bool get hasSelectedImage =>
      kIsWeb ? _selectedImageBytes != null : _selectedImageFile != null;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final offlineService =
          Provider.of<OfflineDeficiencyService>(context, listen: false);

      // Always use offline service to pick image (works in both online and offline modes)
      final pickedImage = await offlineService.pickImage(source: source);

      if (pickedImage != null) {
        setState(() {
          if (kIsWeb) {
            // Web platform returns bytes
            _selectedImageBytes = pickedImage as Uint8List;
            _selectedImageFile = null;
          } else {
            // Mobile platforms return File
            _selectedImageFile = pickedImage as File;
            _selectedImageBytes = null;
          }
          _analysisResult = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (!hasSelectedImage) {
      setState(() {
        _errorMessage = 'Please select an image first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final offlineService =
          Provider.of<OfflineDeficiencyService>(context, listen: false);

      // Ensure model is initialized
      if (!offlineService.isModelInitialized) {
        final initialized = await offlineService.ensureModelInitialized();
        if (!initialized) {
          setState(() {
            _errorMessage = offlineService.errorMessage ??
                'Failed to initialize model. Please restart the app.';
            _isLoading = false;
          });
          return;
        }
      }

      LeafAnalysisResult result;

      // Use the appropriate method based on platform
      if (kIsWeb) {
        // Web platform
        if (_selectedImageBytes == null) {
          throw Exception('Image data is missing');
        }

        // Add more detailed logging for web
        debugPrint(
            'Analyzing image on web platform: ${_selectedImageBytes!.length} bytes');
        result = await offlineService.analyzeImage(_selectedImageBytes!);
      } else {
        // Mobile platform
        if (_selectedImageFile == null) {
          throw Exception('Image file is missing');
        }

        debugPrint(
            'Analyzing image on mobile platform: ${_selectedImageFile!.path}');
        result = await offlineService.analyzeImage(_selectedImageFile!);
      }

      setState(() {
        _analysisResult = result;
      });

      // After analysis, update any context-aware components
      if (_analysisResult != null) {
        debugPrint(
            'Analysis complete: ${_analysisResult!.deficiencyType} detected');
        _passAnalysisToChat(_analysisResult!);
      }
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      setState(() {
        _errorMessage = 'Error analyzing image: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method to pass analysis results to chat context
  void _passAnalysisToChat(LeafAnalysisResult result) {
    // The result is already saved during analysis, log for debugging
    debugPrint('Analysis context available: ${result.deficiencyType}');

    // Navigation is now handled by the button in AnalysisResultCard
    // This method is kept for potential programmatic navigation
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: true);

    // Update service locale when app locale changes
    _apiService.currentLocale = localeProvider.locale;

    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.deficiencyDetection),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              SizedBox(height: 8),
              Text('This may take a moment',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.deficiencyDetection),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status banner (only shows for errors)
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Enhanced Image selection with photography tips
                    if (!hasSelectedImage) 
                      FarmerImagePicker(
                        onCameraPressed: () => _pickImage(ImageSource.camera),
                        onGalleryPressed: () => _pickImage(ImageSource.gallery),
                        isLoading: _isLoading,
                        helpText: localizations.selectImage,
                      ),

                    const SizedBox(height: 16),

                    // Enhanced selected image display
                    if (hasSelectedImage) ...[
                      FarmerImageDisplay(
                        imageSource: kIsWeb ? _selectedImageBytes : _selectedImageFile,
                        deficiencyType: _analysisResult?.deficiencyType,
                        confidence: _analysisResult?.confidence ?? 0.0,
                        onRetake: () {
                          setState(() {
                            _selectedImageFile = null;
                            _selectedImageBytes = null;
                            _analysisResult = null;
                            _errorMessage = null;
                          });
                        },
                        onAnalyze: _analyzeImage,
                        isAnalyzing: _isLoading,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Analysis results
                    if (_analysisResult != null)
                      AnalysisResultCard(result: _analysisResult!),
                  ],
                ),
              ),
            ),
    );
  }

  // Build the appropriate image display widget based on platform

}
