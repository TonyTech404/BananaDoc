#!/bin/bash

# Exit on error
set -e

echo "Creating fixed TFLite model for mobile testing..."

# Create model directory if it doesn't exist
mkdir -p assets/models

# Create a dummy TFLite model file
cat > assets/models/banana_mobile_model.tflite << EOL
TFL3
EOL

# Create a labels file
cat > assets/models/labels.txt << EOL
Healthy
Nitrogen
Phosphorus
Potassium
Calcium
Magnesium
Sulphur
Iron
EOL

# Create a metadata file
cat > assets/models/model_metadata.json << EOL
{
  "model_type": "classification",
  "input_shape": [1, 224, 224, 3],
  "output_shape": [1, 8],
  "labels": [
    "Healthy",
    "Nitrogen",
    "Phosphorus",
    "Potassium",
    "Calcium",
    "Magnesium",
    "Sulphur",
    "Iron"
  ],
  "is_mock": true,
  "creation_date": "2023-05-12"
}
EOL

echo "Files created successfully in assets/models/ directory"
echo "Now cleaning and rebuilding the app..."

# Clean and rebuild the app
flutter clean
flutter pub get

echo "Done! Now run 'flutter run' to test on your device." 