# Setting Up Mobile-Optimized TFLite Model in BananaDoc

This guide explains how to set up and use the mobile-optimized TensorFlow Lite model for offline banana leaf deficiency detection in the BananaDoc app.

## Overview

The mobile-optimized model allows BananaDoc to perform deficiency detection entirely on the device, without requiring an internet connection or the Flask API server. This is perfect for fieldwork in areas with limited connectivity.

## Benefits

- **Offline Operation**: Analyze images without an internet connection
- **Faster Analysis**: No network delay, runs directly on your device
- **Privacy**: Images never leave your device
- **Reduced Battery Usage**: Less network communication
- **Smaller Size**: 70-80% smaller than the full model

## Setup Instructions

### 1. Create the Mobile-Optimized Model

First, you need to create the mobile-optimized model:

```bash
# Make the script executable
chmod +x BananaDoc_AI/model/create_mobile_model.sh

# Run the model creation script
cd BananaDoc_AI/model
./create_mobile_model.sh
```

This script does the following:
- Creates the mobile TFLite model using MobileNetV3Large architecture
- Applies int8 quantization for optimal mobile performance
- Saves the model and metadata files

### 2. Copy Model Files to Flutter Assets

After creating the model, copy it to the Flutter assets directory:

```bash
# Make the script executable
chmod +x copy_models_to_assets.sh

# Run the copy script
./copy_models_to_assets.sh
```

### 3. Update Flutter Dependencies

Make sure your Flutter app has the required dependencies by running:

```bash
flutter pub get
```

## Using Offline Mode

1. Launch the BananaDoc app
2. Go to the "Analyze Image" screen
3. Toggle "Offline Mode" to enable using the on-device model
4. Take or select a photo as usual
5. The app will now process the image entirely on your device

## Troubleshooting

If you encounter issues with the offline mode:

1. **Model Not Found**: Run the `copy_models_to_assets.sh` script again
2. **App Crashes**: Make sure you've run `flutter pub get` to update dependencies
3. **Inaccurate Results**: The mobile model may be slightly less accurate than the full model
4. **Performance Issues**:
   - Try using a device with better processing power
   - Close other apps running in the background

## Technical Details

The mobile TFLite model implementation:

- **Model Architecture**: MobileNetV3Large
- **Input Size**: 224x224 pixels
- **Quantization**: Int8 for optimal size/performance
- **Size**: ~8MB (vs ~38MB for the original model)
- **Classes**: 8 nutrient deficiencies (Boron, Calcium, Healthy, Iron, Magnesium, Manganese, Potassium, Zinc)

## Implementation Files

- `lib/services/tflite_service.dart`: Core service for model loading and inference
- `lib/services/offline_deficiency_service.dart`: Service that manages online/offline switching
- `lib/widgets/offline_mode_toggle.dart`: UI component for toggling offline mode
- `copy_models_to_assets.sh`: Script to copy model files to the assets directory 