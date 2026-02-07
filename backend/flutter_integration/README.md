# Flutter Integration for BananaDoc AI

This directory contains details on how to integrate the BananaDoc AI model with the Flutter app.

## Integration Files

The main files for integration are:

1. `lib/services/nutrient_deficiency_service.dart`: Service to interact with the API
2. `lib/screens/deficiency_detection_screen.dart`: UI for image capturing and analysis 
3. `lib/main.dart`: Added navigation to the deficiency detection screen

## How the Integration Works

1. The Flutter app communicates with the Python Flask API server
2. Images are sent as base64-encoded strings to the `/predict` endpoint
3. The API server processes the image using the pre-trained model
4. Results are returned as JSON with the deficiency type, confidence score, and detailed information
5. The Flutter app displays the results on the Results screen

## API Endpoints

- **POST /predict**: Send an image for analysis
  ```json
  {
    "image": "base64_encoded_image_string"
  }
  ```
  
  Response:
  ```json
  {
    "deficiency": "Potassium",
    "confidence": 0.95,
    "symptoms": "Chlorosis and necrosis at leaf margins...",
    "treatment": "Apply potassium sulfate...",
    "prevention": "Regular soil testing...",
    "probabilities": {
      "Boron": 0.01,
      "Calcium": 0.01,
      ...
    }
  }
  ```

- **GET /health**: Check API server status
- **GET /deficiencies**: Get list of all deficiency types
- **GET /deficiency/{type}**: Get information about a specific deficiency type

## Mobile Device Configuration

When testing on a real device, you'll need to use your computer's local IP address instead of `localhost` in the API URL:

```dart
// In lib/services/nutrient_deficiency_service.dart
static const String apiUrl = 'http://192.168.1.100:5000/predict';  // Replace with your IP
``` 