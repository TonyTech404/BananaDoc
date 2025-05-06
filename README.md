# BananaDoc - AI-Powered Banana Leaf Deficiency App

A Flutter application that uses AI to analyze banana leaf deficiencies and diseases, helping farmers identify nutrient problems in their banana plants.

## Features

- Upload images of banana leaves for analysis
- Describe leaf conditions through text
- Get AI-powered diagnosis of banana leaf issues
- Receive recommended treatments
- Learn prevention measures for future management
- Analyze images using machine learning for nutrient deficiency detection

## Components

### Flutter Application
The main mobile application built with Flutter that provides:
- Chat-based interface for asking questions about banana plant issues
- Image upload and analysis capabilities
- Multilingual support (English and Tagalog)

### BananaDoc AI (Machine Learning)
A machine learning component that:
- Analyzes images of banana leaves to detect nutrient deficiencies
- Identifies 8 types of nutrient deficiencies and healthy leaves
- Provides detailed information about deficiency symptoms, treatments, and preventions

## Setup

### Flutter App
1. Clone this repository
2. Ensure Flutter is installed on your system
3. Run `flutter pub get` to install dependencies
4. Connect a device or emulator
5. Run `flutter run` to start the application

### BananaDoc AI
1. Navigate to the BananaDoc_AI directory
2. Install Python dependencies: `pip install -r requirements.txt`
3. Train the model: `python model/train_model.py` (optional - use pre-trained model)
4. Start the API server: `python run_api.py`

## Technologies Used

- Flutter for cross-platform mobile development
- Google's Gemini API for AI-powered chat analysis
- TensorFlow/Keras for machine learning model development
- Flask for the AI API server
- Image classification with MobileNetV2 transfer learning

## Dataset

The project uses a dataset of banana leaf images showing deficiencies in 8 essential nutrients:
- Boron
- Calcium
- Iron
- Potassium
- Manganese
- Magnesium
- Sulphur
- Zinc

Plus images of healthy leaves.

## Documentation

- [BananaDoc AI Documentation](BananaDoc_AI/README.md)
- [Developer Guide](BananaDoc_AI/docs/developer_guide.md)
- [Flutter Integration Guide](BananaDoc_AI/flutter_integration/README.md)

## Screenshots

(Add screenshots once the app is running)

## Future Improvements

- Implement Gemini Pro Vision for direct image analysis
- Add a history feature to track previous leaf analyses
- Include a database of common banana diseases with images
- Add offline mode for basic diagnostics

## License

This project is licensed under the MIT License.

## API Key Note

The app uses the Google Gemini API. The API key is included in the code for demonstration purposes. In a production environment, you should:

1. Store the API key securely (not in source code)
2. Consider using environment variables or a secure backend
3. Implement proper API key rotation and management 