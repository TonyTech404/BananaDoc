import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/leaf_analysis_result.dart';
import 'tflite_service.dart';

/// Service for handling offline deficiency detection
class OfflineDeficiencyService extends ChangeNotifier {
  // Singleton instance
  static final OfflineDeficiencyService _instance =
      OfflineDeficiencyService._internal();

  // Factory constructor
  factory OfflineDeficiencyService() => _instance;

  // Private constructor
  OfflineDeficiencyService._internal();

  // TFLite service
  final TFLiteService _tfliteService = TFLiteService();
  final ImagePicker _imagePicker = ImagePicker();

  // Flag for offline mode - always true now
  // Note: _offlineMode field removed as it was unused
  bool get offlineMode => true; // Always return true for offline mode

  // Flag for whether model is initialized
  bool _isModelInitialized = false;
  bool get isModelInitialized => _isModelInitialized;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Last analysis result for context awareness
  LeafAnalysisResult? _lastAnalysisResult;
  LeafAnalysisResult? get lastAnalysisResult => _lastAnalysisResult;

  /// Initialize the model (replaces toggle function)
  Future<bool> ensureModelInitialized() async {
    if (_isModelInitialized) return true;

    try {
      _errorMessage = null;
      debugPrint('Initializing TFLite model...');

      final bool initialized = await _tfliteService.initialize();
      _isModelInitialized = initialized;

      if (!initialized) {
        _errorMessage =
            'Failed to initialize TFLite model. Check console for details.';
        debugPrint('Model initialization failed');
      } else {
        debugPrint('Model initialized successfully');
      }

      notifyListeners();
      return initialized;
    } catch (e) {
      debugPrint('Error initializing model: $e');
      _isModelInitialized = false;
      _errorMessage = 'Error initializing model: $e';
      notifyListeners();
      return false;
    }
  }

  /// Legacy toggle function - now just initializes the model
  Future<bool> toggleOfflineMode() async {
    return await ensureModelInitialized();
  }

  /// Initialize the TFLite model
  Future<bool> initializeModel() async {
    return await ensureModelInitialized();
  }

  /// Pick image from camera or gallery (works in offline mode)
  Future<dynamic> pickImage({required ImageSource source}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, return bytes
          return await pickedFile.readAsBytes();
        } else {
          // For mobile, return File
          return File(pickedFile.path);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      _errorMessage = 'Error picking image: $e';
      notifyListeners();
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Analyze image using offline TFLite model or fallback
  Future<LeafAnalysisResult> analyzeImage(dynamic imageData) async {
    // Initialize model if not initialized
    if (!_isModelInitialized) {
      await initializeModel();
      if (!_isModelInitialized) {
        throw Exception('Failed to initialize model. Please try again.');
      }
    }

    try {
      LeafAnalysisResult result;

      if (kIsWeb && imageData is Uint8List) {
        // Handle web platform (using bytes)
        debugPrint('Analyzing web image bytes: ${imageData.length} bytes');
        result = await _tfliteService.analyzeImageWeb(imageData);
      } else if (imageData is File) {
        // Handle mobile platforms (using File)
        debugPrint('Analyzing mobile image file: ${imageData.path}');
        result = await _tfliteService.analyzeImage(imageData);
      } else {
        throw Exception('Unsupported image format: ${imageData.runtimeType}');
      }

      // Store result for context awareness
      _lastAnalysisResult = result;

      return result;
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      _errorMessage = 'Error analyzing image: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Analyze leaf image offline
  Future<LeafAnalysisResult> analyzeLeafOffline(File imageFile) async {
    if (!_isModelInitialized) {
      await initializeModel();
      if (!_isModelInitialized) {
        throw Exception(
            'Model not initialized. Please initialize the model first.');
      }
    }

    try {
      debugPrint('Analyzing leaf offline...');
      final result = await _tfliteService.analyzeImage(imageFile);

      // Store result for context awareness
      _lastAnalysisResult = result;

      return result;
    } catch (e) {
      debugPrint('Error analyzing leaf offline: $e');
      rethrow;
    }
  }

  /// Get context information for chat
  String getContextForChat() {
    if (_lastAnalysisResult == null) {
      return "No plant analysis has been performed yet.";
    }

    return "Last Analysis:\n"
        "Deficiency: ${_lastAnalysisResult!.deficiencyType}\n"
        "Confidence: ${(_lastAnalysisResult!.confidence * 100).toStringAsFixed(2)}%\n"
        "Diagnosis: ${_lastAnalysisResult!.diagnosis}\n"
        "Treatment: ${_lastAnalysisResult!.treatment}\n"
        "Prevention: ${_lastAnalysisResult!.prevention}";
  }

  /// Dispose of resources
  @override
  void dispose() {
    _tfliteService.dispose();
    super.dispose();
  }
}
