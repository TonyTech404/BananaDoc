import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../widgets/custom_button.dart';

class FarmerImagePicker extends StatelessWidget {
  final VoidCallback? onCameraPressed;
  final VoidCallback? onGalleryPressed;
  final bool isLoading;
  final String? helpText;

  const FarmerImagePicker({
    super.key,
    this.onCameraPressed,
    this.onGalleryPressed,
    this.isLoading = false,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final resolvedHelp = helpText ?? localizations.takePhoto;

  return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon and title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            localizations.selectImage,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (resolvedHelp.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              resolvedHelp,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Camera button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: localizations.takePhoto,
              onPressed: isLoading ? null : onCameraPressed,
              icon: Icons.camera_alt,
              size: ButtonSize.large,
              isLoading: isLoading,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Gallery button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: localizations.gallery,
              onPressed: isLoading ? null : onGalleryPressed,
              icon: Icons.photo_library,
              type: ButtonType.outlined,
              size: ButtonSize.large,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tips section
          _buildTipsSection(context, localizations),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context, AppLocalizations localizations) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.photographyTips,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildTip(context, Icons.wb_sunny, localizations.tip1GoodLighting),
          const SizedBox(height: 8),
          _buildTip(context, Icons.center_focus_strong, localizations.tip2CloseUp),
          const SizedBox(height: 8),
          _buildTip(context, Icons.filter_center_focus, localizations.tip3ClearFocus),
        ],
      ),
    );
  }

  Widget _buildTip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blue.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade800,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

// Enhanced Image Display Widget
class FarmerImageDisplay extends StatelessWidget {
  final dynamic imageSource; // Can be File, Uint8List, or String
  final String? deficiencyType;
  final double confidence;
  final VoidCallback? onRetake;
  final VoidCallback? onAnalyze;
  final bool isAnalyzing;

  const FarmerImageDisplay({
    super.key,
    required this.imageSource,
    this.deficiencyType,
    this.confidence = 0.0,
    this.onRetake,
    this.onAnalyze,
    this.isAnalyzing = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: _buildImageWidget(),
            ),
          ),
          
          // Image info section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.selectedImage,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (onRetake != null)
                      TextButton.icon(
                        onPressed: onRetake,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(localizations.retake),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                
                if (deficiencyType != null && confidence > 0) ...[
                  const SizedBox(height: 12),
                  _buildResultPreview(context, deficiencyType!, confidence),
                ] else if (onAnalyze != null) ...[
                  const SizedBox(height: 16),
                  // Analysis status indicator
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.offline_bolt, color: Colors.green.shade700),
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
                  const SizedBox(height: 16),
                  // Analyze button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: localizations.analyze,
                      onPressed: isAnalyzing ? null : onAnalyze,
                      icon: Icons.search,
                      size: ButtonSize.large,
                      isLoading: isAnalyzing,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // Handle different image source types
    if (imageSource is String) {
      return Image.network(
        imageSource as String,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    } else if (imageSource is File) {
      // Handle File for mobile platforms
      return Image.file(
        imageSource as File,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    } else if (imageSource is Uint8List) {
      // Handle Uint8List for web platform
      return Image.memory(
        imageSource as Uint8List,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error, color: Colors.red),
          );
        },
      );
    }
    
    // Fallback for unknown types
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildResultPreview(BuildContext context, String deficiency, double confidence) {
    final theme = Theme.of(context);
    final confidencePercent = (confidence * 100).toInt();
    
    Color statusColor = Colors.grey;
    if (deficiency.toLowerCase() == 'healthy') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              deficiency.toLowerCase() == 'healthy' 
                  ? Icons.check 
                  : Icons.warning,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deficiency,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                Text(
                  '$confidencePercent% confidence',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}