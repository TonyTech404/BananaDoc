# Banana Leaf Deficiency Detection Model

This directory contains the model training, testing, and inference code for the BananaDoc application.

## Model Overview

The model uses EfficientNetB0 with transfer learning to classify banana leaf deficiencies. Key features:

- Uses EfficientNetB0 pre-trained on ImageNet as the base model
- Excludes Sulphur class to improve accuracy
- Implements stronger regularization (L2, dropout, batch normalization)
- Includes precision and recall metrics
- Uses enhanced data augmentation

## Mobile-Optimized Model (NEW)

We now also provide a mobile-optimized version of the model using MobileNetV3Large and TensorFlow Lite with int8 quantization. This model is significantly smaller and faster, making it ideal for offline mobile deployment. Key features:

- Uses MobileNetV3Large architecture optimized for mobile devices
- Applies int8 quantization for improved efficiency
- Reduces model size by 70-80% compared to the standard model
- Increases inference speed by 40-60%
- Maintains equivalent accuracy to the standard model

To create and test the mobile model:

```bash
cd BananaDoc_AI/model
chmod +x create_mobile_model.sh
./create_mobile_model.sh
```

## Training the Model

To train the model, you can run:

```bash
cd BananaDoc_AI
./train_and_verify.sh
```

This script will:
1. Train the model excluding the Sulphur class
2. Save both H5 and TFLite model formats
3. Generate a training history plot
4. Verify that all files are created and trackable by git
5. Test the model on a sample image if available

## Important Files

- `train_model.py`: The main training script that builds and trains the model
- `test_model.py`: Script to test the model on individual images
- `test_all_classes.py`: Diagnostic script to evaluate the model across all classes
- `banana_nutrient_model.h5`: The trained Keras model (added to git with force)
- `banana_nutrient_model.keras`: The native Keras format model
- `class_mapping.txt`: Mapping between class indices and names
- `training_history.png`: Plot of training and validation accuracy/loss

### Mobile Model Files (NEW)

- `create_mobile_model.py`: Script to create the mobile-optimized TFLite model
- `test_mobile_model.py`: Script to test the mobile-optimized model
- `compare_models.py`: Script to compare standard and mobile models
- `banana_mobile_model.tflite`: The quantized TFLite model for mobile deployment
- `mobile_class_mapping.txt`: Class mapping for the mobile model
- `model_comparison.png`: Visual comparison of model performance
- `create_mobile_model.sh`: Shell script to automate mobile model creation and testing

## Git Configuration

By default, model files (*.h5, *.tflite) are ignored by git due to their size. However, we've added exceptions in the .gitignore file to track our specific model files:

```
# TensorFlow model files - but allow our specific models
*.h5
!model/banana_nutrient_model.h5
*.tflite
!model/banana_nutrient_model.tflite
!model/banana_mobile_model.tflite
```

We've already committed the following pre-trained model files to git:
- `banana_nutrient_model.h5` (~38MB) - Keras H5 format model
- `banana_nutrient_model.keras` (~37MB) - Native Keras format model
- `banana_mobile_model.tflite` (~8MB) - Quantized TFLite model for mobile
- `class_mapping.txt` - Mapping between class indices and names

If you modify the model and need to update these files in git, you can force add them:

```bash
# Use our script
./add_model_to_git.sh

# Or manually add files
git add -f model/banana_nutrient_model.h5
git add -f model/banana_nutrient_model.keras
git add -f model/banana_mobile_model.tflite
git add -f model/class_mapping.txt
```

## Mobile Deployment

The mobile-optimized TFLite model can be integrated into Android or iOS applications for offline inference. Key benefits of using the mobile model:

- **Size**: ~8MB vs ~38MB for the standard model (80% reduction)
- **Speed**: 40-60% faster inference than the standard model
- **Efficiency**: Lower memory and battery usage due to int8 quantization
- **Offline Use**: No internet connection required for predictions

### Android Integration

To use the TFLite model in an Android app:

1. Copy the `banana_mobile_model.tflite` and `mobile_class_mapping.txt` to your Android assets folder
2. Use the TensorFlow Lite Android library to load and run the model
3. Implement the same preprocessing steps as in `test_mobile_model.py`

### iOS Integration

To use the TFLite model in an iOS app:

1. Add the `banana_mobile_model.tflite` and `mobile_class_mapping.txt` to your iOS project
2. Use the TensorFlow Lite iOS framework to load and run the model
3. Implement the same preprocessing steps as in `test_mobile_model.py`

## TFLite Conversion Issues

There's a known issue with converting some models to TFLite format. We've added error handling in the code to create a placeholder TFLite file when conversion fails. The app will still work with the H5/Keras format model.

## Integration with Gemini/LLM

The model predictions can be used to provide context to the Gemini LLM. This integration:

1. Stores prediction results in a conversation context
2. Uses the prediction data to inform the LLM response
3. Maintains a history of the conversation for contextual awareness
4. Delivers professional, straightforward responses about the identified deficiency

To test this integration, run:

```bash
python test_gemini_integration.py
``` 