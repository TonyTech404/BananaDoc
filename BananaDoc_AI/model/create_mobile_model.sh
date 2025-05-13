#!/bin/bash

# Exit on error
set -e

# Directory setup
cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"
MODEL_DIR="${SCRIPT_DIR}"
echo "Working directory: ${SCRIPT_DIR}"

# Check Python dependencies
echo "Checking Python dependencies..."
python -c "import tensorflow as tf; print(f'TensorFlow version: {tf.__version__}')"
python -c "import numpy as np; print(f'NumPy version: {np.__version__}')"
python -c "import PIL; print(f'PIL version: {PIL.__version__}')"

# Check if Python script exists
if [ ! -f "create_mobile_model.py" ]; then
    echo "Error: create_mobile_model.py script not found"
    exit 1
fi

echo ""
echo "=== STEP 1: CREATING MOBILE-OPTIMIZED MODEL ==="
python create_mobile_model.py

# Check if model files were created
if [ -f "${MODEL_DIR}/banana_mobile_model.keras" ]; then
    echo "✅ Mobile model created successfully: $(du -h ${MODEL_DIR}/banana_mobile_model.keras | cut -f1)"
else
    echo "❌ Failed to create mobile model"
    exit 1
fi

if [ -f "${MODEL_DIR}/mobile_class_mapping.txt" ]; then
    echo "✅ Class mapping created"
    echo "Class mapping contents:"
    cat "${MODEL_DIR}/mobile_class_mapping.txt"
else
    echo "❌ Class mapping file not found"
    exit 1
fi

echo ""
echo "=== STEP 2: COPY FILES TO FLUTTER ASSETS ==="
FLUTTER_ASSETS_DIR="../../assets/models"
if [ ! -d "$FLUTTER_ASSETS_DIR" ]; then
    mkdir -p "$FLUTTER_ASSETS_DIR"
    echo "Created Flutter assets directory: $FLUTTER_ASSETS_DIR"
fi

# Copy the model files to Flutter assets
cp "${MODEL_DIR}/banana_mobile_model.keras" "${FLUTTER_ASSETS_DIR}/banana_mobile_model.tflite"
cp "${MODEL_DIR}/mobile_class_mapping.txt" "${FLUTTER_ASSETS_DIR}/"
cp "${MODEL_DIR}/banana_mobile_model_metadata.txt" "${FLUTTER_ASSETS_DIR}/"

echo "✅ Model files copied to Flutter assets"
echo "Mobile model ready for use in the Flutter app!"

# Display file sizes
echo ""
echo "=== MODEL SIZE COMPARISON ==="
if [ -f "${MODEL_DIR}/banana_nutrient_model.h5" ]; then
    echo "Original model: $(du -h ${MODEL_DIR}/banana_nutrient_model.h5 | cut -f1)"
fi
echo "Mobile model: $(du -h ${MODEL_DIR}/banana_mobile_model.keras | cut -f1)"
echo "TFLite model (for Flutter): $(du -h ${FLUTTER_ASSETS_DIR}/banana_mobile_model.tflite | cut -f1)"

echo ""
echo "To use this model in your Flutter app, run:"
echo "flutter clean && flutter pub get" 