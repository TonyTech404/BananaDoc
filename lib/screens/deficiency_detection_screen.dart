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
import '../widgets/image_display.dart';
import '../screens/chat_screen.dart';
import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../services/tflite_service.dart';

class DeficiencyDetectionScreen extends StatefulWidget {
  const DeficiencyDetectionScreen({Key? key}) : super(key: key);

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
    final offlineService =
        Provider.of<OfflineDeficiencyService>(context, listen: false);
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
    // Store the result in the offline service for context awareness
    final offlineService =
        Provider.of<OfflineDeficiencyService>(context, listen: false);

    // The result is already saved during analysis, but log for debugging
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(localizations.analyzing),
              const SizedBox(height: 8),
              const Text('This may take a moment',
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'en') {
                localeProvider.setLocale(const Locale('en', ''));
                // Also update TFLite service locale
                final tfliteService = TFLiteService();
                tfliteService.currentLocale = const Locale('en', '');
                // Force refresh UI
                setState(() {});
              } else if (value == 'tl') {
                localeProvider.setLocale(const Locale('tl', ''));
                // Also update TFLite service locale
                final tfliteService = TFLiteService();
                tfliteService.currentLocale = const Locale('tl', '');
                // Force refresh UI
                setState(() {});
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    if (localeProvider.locale.languageCode == 'en')
                      const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(localizations.english),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'tl',
                child: Row(
                  children: [
                    if (localeProvider.locale.languageCode == 'tl')
                      const Icon(Icons.check, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(localizations.filipino),
                    ),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.language),
            tooltip: localizations.selectLanguage,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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

                    // Image selection buttons
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.eco, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    localizations.deficiencyDetection,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizations.selectImage,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildImageSourceButton(
                                  icon: Icons.photo_library,
                                  label: localizations.gallery,
                                  onPressed: () =>
                                      _pickImage(ImageSource.gallery),
                                ),
                                _buildImageSourceButton(
                                  icon: Icons.camera_alt,
                                  label: localizations.camera,
                                  onPressed: () =>
                                      _pickImage(ImageSource.camera),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Selected image display
                    if (hasSelectedImage) ...[
                      _buildImageDisplay(localizations),
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
  Widget _buildImageDisplay(AppLocalizations localizations) {
    final offlineService =
        Provider.of<OfflineDeficiencyService>(context, listen: false);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade700, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.offline_bolt, color: Colors.green.shade800),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Analysis will be performed directly on your device',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? Image.memory(
                      _selectedImageBytes!,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      _selectedImageFile!,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _analyzeImage,
              icon: const Icon(
                Icons.search,
                size: 24,
              ),
              label: Text(
                localizations.analyze,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.green.shade600,
          ),
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
