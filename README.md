# BananaDoc - AI-Powered Banana Leaf Deficiency App

A Flutter application that uses AI to analyze banana leaf deficiencies and diseases, helping farmers identify nutrient problems in their banana plants.

## System Architecture

```
┌─────────────────┐           ┌─────────────────┐
│                 │           │                 │
│  Flutter App    │◄─────────►│  BananaDoc AI   │
│  (Frontend)     │    API    │  (Backend)      │
│                 │  Calls    │                 │
└────────┬────────┘           └────────┬────────┘
         │                             │
         │                             │
         ▼                             ▼
┌─────────────────┐           ┌─────────────────┐
│                 │           │                 │
│ Local Storage   │           │ TensorFlow      │
│ (User Data)     │           │ ML Model        │
│                 │           │                 │
└─────────────────┘           └─────────────────┘
         │                             ▲
         │                             │
         ▼                             │
┌─────────────────┐           ┌─────────────────┐
│                 │           │                 │
│ Gemini API      │───────────► Neural Network  │
│ (Chat Analysis) │           │Training Data    │
│                 │           │                 │
└─────────────────┘           └─────────────────┘
```

## Features

- Upload images of banana leaves for analysis
- Describe leaf conditions through text
- Get AI-powered diagnosis of banana leaf issues
- Receive recommended treatments
- Learn prevention measures for future management
- Analyze images using machine learning for nutrient deficiency detection
- **NEW: Offline Mode** - Analyze leaves without internet using on-device TFLite model

## Setup and Installation

### Prerequisites

- Flutter SDK (2.0 or later)
- Python 3.8+ 
- Node.js (optional, for additional tools)
- Chrome browser (for testing web version)

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/BananaDoc.git
cd BananaDoc
```

### 2. Set Up the BananaDoc AI Backend

```bash
# Navigate to the AI directory
cd BananaDoc_AI

# Create and activate a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the API server
# IMPORTANT: Must use port 5002 for Flutter app compatibility
python run_api.py
```

The API server will start at http://localhost:5002

### 3. Set Up the Mobile-Optimized Model (Optional)

For offline usage, you'll need to set up the mobile-optimized TFLite model:

```bash
# Make the scripts executable
chmod +x BananaDoc_AI/model/create_mobile_model.sh
chmod +x copy_models_to_assets.sh

# Create the mobile model
cd BananaDoc_AI/model
./create_mobile_model.sh
cd ../..

# Copy model files to Flutter assets
./copy_models_to_assets.sh
```

See [MOBILE_MODEL_SETUP.md](MOBILE_MODEL_SETUP.md) for detailed instructions.

### 4. Set Up the Flutter App

```bash
# Get Flutter dependencies
flutter pub get

# Run the app on your preferred device
flutter run

# For web specifically
flutter run -d chrome
```

## Usage Instructions

### Image Analysis

1. Navigate to the "Analyze Image" section
2. Upload an image of a banana leaf or take a photo
3. The app will process the image and identify any nutrient deficiencies
4. Review the diagnosis, treatment recommendations, and prevention tips

### Offline Mode (NEW)

1. From the "Analyze Image" screen, toggle "Offline Mode" on
2. Take or select a photo as usual
3. The app will process the image entirely on your device, without internet
4. Perfect for fieldwork in areas with limited connectivity

### Text-Based Analysis

1. From the home screen, type a description of the leaf symptoms
2. The AI will analyze your description and suggest possible deficiencies
3. Follow up with questions about treatment or prevention

### Chatbot Interaction

After a deficiency has been identified:
1. Ask specific questions about the deficiency
2. The chatbot maintains context of the conversation
3. You can ask follow-up questions like "what should I do?" or "anong gagawin ko?"
4. The system will provide tailored advice for the identified deficiency

## API Documentation

The BananaDoc AI system exposes several API endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Check if API server is running |
| `/predict` | POST | Submit an image for analysis |
| `/deficiencies` | GET | Get list of all possible deficiencies |
| `/deficiency/{type}` | GET | Get details about a specific deficiency |

### Example API usage:

```bash
# Check API health
curl http://localhost:5002/health

# Analyze an image (base64 encoded)
curl -X POST -H "Content-Type: application/json" \
  -d '{"image": "base64_encoded_image_string"}' \
  http://localhost:5002/predict
```

## Important Configuration Notes

1. The Flutter app expects the API server to run on port 5002
2. In `lib/services/llm_service.dart`, the API connection is configured:
   ```dart
   static const String _baseUrlMobile = 'http://localhost:5002';
   static const String _baseUrlWeb = 'http://127.0.0.1:5002';
   ```
3. For running on physical devices, update the baseUrl to your computer's IP address

## Troubleshooting

1. **API Connection Issues**: Ensure the API server is running on port 5002
2. **Image Upload Problems**: Check for adequate permissions on your device
3. **Context Awareness Issues**: If the chatbot loses context, try starting a new conversation

## Dataset Information

The machine learning model was trained on images of banana leaves showing deficiencies in 8 essential nutrients:
- Boron
- Calcium
- Iron
- Potassium
- Manganese
- Magnesium
- Sulphur
- Zinc

Plus images of healthy leaves.

## Image of our Project
<img width="343" height="689" alt="image" src="https://github.com/user-attachments/assets/a5d8eab4-4f1f-409b-a1ab-efe5cf11a8de" />


## Video demo of the Project
https://drive.google.com/file/d/1wTVHkPJ-G0bRKLdhjYB6v9epY1ql4kNR/view?usp=sharing

## License

This project is licensed under the MIT License.

## API Key Note

The app uses the Google Gemini API. The API key is included in the code for demonstration purposes. In a production environment, you should:

1. Store the API key securely (not in source code)
2. Consider using environment variables or a secure backend
3. Implement proper API key rotation and management
