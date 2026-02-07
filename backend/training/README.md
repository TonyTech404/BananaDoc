# Model Training Directory

This directory contains all scripts and files related to **training and developing** the banana leaf deficiency detection models.

## ⚠️ Important Note

**This directory is for model development only.** The trained models are stored in `../models_runtime/` and used by the application.

## Contents

### Training Scripts
- `train_model.py` - Main script to train the EfficientNetB0-based model
- `create_mobile_model.py` - Creates mobile-optimized TFLite models
- `create_mobile_model.sh` - Shell script to automate mobile model creation
- `finetune_mobile_model.py` - Fine-tuning script for mobile models
- `compare_models.py` - Compare standard and mobile model performance
- `convert_to_tflite.py` - Convert Keras models to TFLite format

### Training Artifacts
- `finetuned_mobile_model.keras` - Fine-tuned mobile model (development)
- `training_history.png` - Training accuracy/loss plots
- `finetuning_history.png` - Fine-tuning history plots

## Usage

### Training a New Model

1. **Prepare your dataset:**
   - Place your training images in a directory structure like:
     ```
     dataset/
       ├── Boron/
       ├── Calcium/
       ├── Healthy/
       ├── Iron/
       ├── Magnesium/
       ├── Manganese/
       ├── Potassium/
       └── Zinc/
     ```

2. **Update paths in `train_model.py`:**
   - Modify `raw_data_dir` and `augmented_data_dir` to point to your dataset

3. **Run training:**
   ```bash
   cd BananaDoc_AI/training
   python train_model.py
   ```

4. **After training, move models to runtime:**
   ```bash
   # Copy trained models to models_runtime directory
   cp banana_nutrient_model.h5 ../models_runtime/
   cp banana_nutrient_model.keras ../models_runtime/
   cp banana_nutrient_model.tflite ../models_runtime/
   cp class_mapping.txt ../models_runtime/
   ```

### Creating Mobile Models

```bash
cd BananaDoc_AI/training
chmod +x create_mobile_model.sh
./create_mobile_model.sh
```

This will create optimized TFLite models in the `models_runtime/` directory.

## Model Outputs

After training, models should be moved to `../models_runtime/` for use by the application. The runtime directory contains:

- `banana_nutrient_model.h5` - Standard Keras model
- `banana_nutrient_model.keras` - Native Keras format
- `banana_nutrient_model.tflite` - Standard TFLite model
- `banana_mobile_model.tflite` - Mobile-optimized TFLite model
- `class_mapping.txt` - Class index to name mapping
- `mobile_class_mapping.txt` - Mobile model class mapping

## Notes

- Training requires a large dataset (thousands of images per class)
- Training can take several hours depending on hardware
- Models are excluded from git by default (see `.gitignore`)
- Always test models before deploying to production
