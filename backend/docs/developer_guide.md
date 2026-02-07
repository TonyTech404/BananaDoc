# BananaDoc AI Developer Guide

This guide provides more detailed information for developers working on the BananaDoc AI project.

## Development Setup

### Prerequisites

- Python 3.7 or higher
- TensorFlow 2.x
- Flask
- NumPy, Pillow, Matplotlib
- Flutter SDK (for app integration)

### Environment Setup

It's recommended to use a virtual environment:

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment (macOS/Linux)
source venv/bin/activate

# Activate virtual environment (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

## Project Architecture

### Machine Learning Component

The ML component follows this workflow:
1. **Data preparation**: Images are loaded from the dataset directories
2. **Data augmentation**: During training, images are augmented to improve generalization
3. **Model training**: A MobileNetV2-based transfer learning model is trained
4. **Model evaluation**: The model is evaluated on validation data
5. **Model export**: The trained model is saved in both .h5 and .tflite formats

### API Component

The API follows a RESTful design:
1. **Image receiving**: Images are received as base64-encoded strings
2. **Preprocessing**: Images are decoded and preprocessed for the model
3. **Prediction**: The model makes a prediction on the image
4. **Response**: The prediction and additional information are returned as JSON

### Flutter Integration

The Flutter app integration involves:
1. **Image capture**: Using device camera or gallery
2. **API communication**: Sending images to the API and receiving results
3. **Results display**: Showing the deficiency details to the user

## Code Organization

### Core Modules

- **utils/image_preprocessor.py**: Contains functions for image preprocessing
- **utils/model_loader.py**: Handles loading of trained models
- **utils/deficiency_info.py**: Provides information about nutrient deficiencies

### Key Classes

- **BananaLeafDeficiencyModelTrainer**: Handles the entire training pipeline
- **ModelLoader**: Loads and manages the trained model
- **DeficiencyInfoProvider**: Provides detailed information about deficiencies

## Extending the Project

### Adding New Deficiency Types

1. Update the deficiency types in `utils/deficiency_info.py`
2. Add new image data to the dataset
3. Retrain the model with the updated data

### Improving the Model

To improve model performance:
1. Add more diverse training data
2. Experiment with different model architectures in `model/train_model.py`
3. Try different hyperparameters (learning rate, batch size, etc.)
4. Implement more advanced data augmentation techniques

### Adding New API Endpoints

To add new API functionality:
1. Add new routes to `api/banana_deficiency_api.py`
2. Update the Flask application with the new endpoints
3. Update the Flutter service to use the new endpoints

## Troubleshooting

### Common Issues

- **Model not found**: Ensure you've trained the model and it's saved in the correct location
- **API connection errors**: Check that the API server is running and accessible
- **Image preprocessing errors**: Verify the image format and dimensions
- **Low prediction accuracy**: Consider retraining with more data or tweaking the model

### Debugging

- Enable detailed logging in the API by adding `app.logger.setLevel(logging.DEBUG)` 
- Use TensorFlow's debugging tools for model issues
- For Flutter integration issues, check network traffic using tools like Charles Proxy 