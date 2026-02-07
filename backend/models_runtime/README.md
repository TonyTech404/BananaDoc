# Runtime Models Directory

This directory contains the **trained models** used by the BananaDoc application at runtime.

## ⚠️ Important

**Do not modify files in this directory manually.** These are production models used by the API and mobile app.

## Contents

### Model Files
- `banana_nutrient_model.h5` - Standard Keras model (H5 format)
- `banana_nutrient_model.keras` - Native Keras format model
- `banana_nutrient_model.tflite` - Standard TensorFlow Lite model
- `banana_mobile_model.keras` - Mobile Keras model
- `banana_mobile_model.tflite` - Mobile-optimized TFLite model (for Flutter app)

### Metadata Files
- `class_mapping.txt` - Maps class indices to deficiency names
- `mobile_class_mapping.txt` - Class mapping for mobile model
- `labels.txt` - Class labels list
- `model_metadata.json` - Model metadata and configuration
- `banana_mobile_model_metadata.txt` - Mobile model metadata

## Usage

These models are automatically loaded by:
- `utils/model_loader.py` - For API server
- Flutter app - Uses TFLite models from `assets/models/`

## Updating Models

To update models:

1. Train new models in `../training/` directory
2. Copy new model files to this directory:
   ```bash
   cp ../training/banana_nutrient_model.* .
   cp ../training/banana_mobile_model.tflite .
   cp ../training/class_mapping.txt .
   ```
3. Test the API to ensure models load correctly
4. Update Flutter app assets if mobile model changed

## File Sizes

- `banana_nutrient_model.h5`: ~39MB
- `banana_nutrient_model.keras`: ~39MB
- `banana_nutrient_model.tflite`: ~6MB
- `banana_mobile_model.tflite`: ~4MB

These files are tracked in git (see `.gitignore` exceptions).

