# Banana Nutrient Deficiency Detection Model

This project adds nutrient deficiency detection capabilities to the BananaDoc application. It uses machine learning to analyze images of banana leaves and identify deficiencies in essential nutrients.

## Components

1. **Machine Learning Model (Python)**
   - `train_model.py`: Trains a deep learning model on the provided dataset
   - `test_model.py`: Tests the model on individual images
   - `banana_deficiency_api.py`: Provides a Flask API to serve model predictions
   - `requirements.txt`: Lists Python dependencies

2. **Flutter Integration**
   - `lib/services/nutrient_deficiency_service.dart`: Service to interact with the ML model API
   - `lib/screens/deficiency_detection_screen.dart`: UI for uploading and analyzing images

## Dataset

The dataset consists of images of banana leaves showing deficiencies in 8 essential nutrients:
- Boron
- Calcium
- Iron
- Potassium
- Manganese
- Magnesium
- Sulphur
- Zinc

Plus images of healthy leaves.

## Setup Instructions

### Step 1: Set Up Python Environment

1. Make sure you have Python 3.7+ installed
2. Install required Python packages:
   ```
   pip install -r requirements.txt
   ```

### Step 2: Train the Model

1. Run the training script:
   ```
   python train_model.py
   ```
   This will train the model using the provided dataset and save the model as `banana_nutrient_model.h5` and `banana_nutrient_model.tflite`.

### Step 3: Start the Flask API Server

1. Run the API server:
   ```
   python banana_deficiency_api.py
   ```
   The server will start on `localhost:5000`.

### Step 4: Use the Flutter App

1. Make sure Flutter is set up on your system
2. Run the app:
   ```
   flutter run
   ```
3. In the app, navigate to the "Detect" tab using the bottom navigation bar
4. Upload a banana leaf image using the camera or gallery
5. Click "Analyze Leaf" to get the prediction

## Testing the Model Directly

You can test the model on individual images without the Flutter app using:

```
python test_model.py path/to/image.jpg
```

This will display the image with the prediction and confidence score.

## Model Architecture

The model uses transfer learning based on MobileNetV2 pretrained on ImageNet. The architecture includes:
- MobileNetV2 base model (frozen layers)
- Global Average Pooling
- Dense layer (1024 neurons, ReLU activation)
- Dropout (0.5)
- Dense layer (512 neurons, ReLU activation)
- Dropout (0.3)
- Output layer (9 neurons, Softmax activation)

## Limitations and Future Improvements

- The model works best with clear, well-lit images of banana leaves
- Background removal and proper framing of the leaf will improve results
- Consider deploying the model directly in the Flutter app using TensorFlow Lite to eliminate the need for a separate server 