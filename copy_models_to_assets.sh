#!/bin/bash

# Script to copy the TFLite model files to the Flutter assets directory

# Set working directory to script location
cd "$(dirname "$0")"
echo "Working directory: $(pwd)"

# Create the assets/models directory if it doesn't exist
mkdir -p assets/models
echo "Created assets/models directory"

# Check if the mobile model exists
MOBILE_MODEL="BananaDoc_AI/model/banana_mobile_model.tflite"
METADATA="BananaDoc_AI/model/banana_mobile_model_metadata.txt"
CLASS_MAPPING="BananaDoc_AI/model/mobile_class_mapping.txt"

if [ ! -f "$MOBILE_MODEL" ]; then
    echo "Mobile model not found at $MOBILE_MODEL"
    echo "Creating the mobile model first..."
    
    # Check if create_mobile_model.sh exists and is executable
    if [ -f "BananaDoc_AI/model/create_mobile_model.sh" ] && [ -x "BananaDoc_AI/model/create_mobile_model.sh" ]; then
        # Execute the script to create the mobile model
        echo "Running create_mobile_model.sh..."
        cd BananaDoc_AI/model
        ./create_mobile_model.sh
        cd ../..
    else
        echo "Error: create_mobile_model.sh not found or not executable."
        echo "Please create the mobile model first by running:"
        echo "cd BananaDoc_AI/model && chmod +x create_mobile_model.sh && ./create_mobile_model.sh"
        exit 1
    fi
fi

# Check again if the model exists after creation attempt
if [ ! -f "$MOBILE_MODEL" ]; then
    echo "Error: Mobile model still not found after creation attempt."
    exit 1
fi

# Copy the model files to assets directory
echo "Copying model files to Flutter assets..."
cp "$MOBILE_MODEL" assets/models/
cp "$CLASS_MAPPING" assets/models/
[ -f "$METADATA" ] && cp "$METADATA" assets/models/

echo "Model files copied successfully!"
echo ""
echo "The following files were copied:"
echo "- $(basename "$MOBILE_MODEL") -> assets/models/"
echo "- $(basename "$CLASS_MAPPING") -> assets/models/"
[ -f "$METADATA" ] && echo "- $(basename "$METADATA") -> assets/models/"

echo ""
echo "To use these models in your Flutter app:"
echo "1. Run 'flutter clean'"
echo "2. Run 'flutter pub get'"
echo "3. Rebuild the app"

# Update pubspec.yaml if needed
if ! grep -q "assets/models/" pubspec.yaml; then
    echo ""
    echo "Warning: The pubspec.yaml file may not include the models directory in assets."
    echo "Please ensure your pubspec.yaml includes:"
    echo ""
    echo "flutter:"
    echo "  assets:"
    echo "    - assets/models/"
fi 