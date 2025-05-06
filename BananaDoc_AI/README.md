# BananaDoc AI - Banana Leaf Nutrient Deficiency Detection

This project uses machine learning to detect nutrient deficiencies in banana plant leaves from images. It integrates with the BananaDoc Flutter application.

## Project Structure

```
BananaDoc_AI/
├── model/                  # Model training and testing
│   ├── train_model.py      # Script to train the model
│   ├── test_model.py       # Script to test the model on images
│   └── class_mapping.txt   # Generated mapping of class indices to names
│
├── api/                    # API server for model predictions
│   └── banana_deficiency_api.py  # Flask API to serve model predictions
│
├── utils/                  # Utility functions
│   ├── image_preprocessor.py     # Image preprocessing utilities
│   ├── model_loader.py           # Model loading utilities
│   └── deficiency_info.py        # Deficiency information provider
│
├── docs/                   # Documentation
│   └── README.md           # Detailed documentation
│
└── requirements.txt        # Python dependencies
```

## Setup and Usage

### Installation

1. Install Python dependencies:

```bash
pip install -r requirements.txt
```

### Training the Model

1. Navigate to the project directory
2. Run the training script:

```bash
cd model
python train_model.py
```

This will:
- Load the banana leaf images from the dataset
- Train a MobileNetV2-based model
- Save the model as `banana_nutrient_model.h5` and `banana_nutrient_model.tflite`
- Save the class mapping as `class_mapping.txt`
- Generate a training history plot as `training_history.png`

### Testing the Model

Test the model on individual images:

```bash
cd model
python test_model.py path/to/image.jpg
```

This will display the image with the prediction and provide detailed information about the detected deficiency.

### Running the API Server

Start the Flask API server:

```bash
cd api
python banana_deficiency_api.py
```

The server will start on `localhost:5000` with the following endpoints:

- **POST /predict**: Analyze an image and return the deficiency prediction
- **GET /health**: Check if the API is healthy
- **GET /deficiencies**: Get a list of all deficiency types
- **GET /deficiency/<type>**: Get information about a specific deficiency

## Integration with Flutter App

The model is integrated with the BananaDoc Flutter application. The integration code is located in:

- `lib/services/nutrient_deficiency_service.dart`
- `lib/screens/deficiency_detection_screen.dart`

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

## Model Architecture

The model uses transfer learning based on MobileNetV2:
- MobileNetV2 base model (frozen)
- Global Average Pooling
- Dense layer (1024 neurons, ReLU)
- Dropout (0.5)
- Dense layer (512 neurons, ReLU)
- Dropout (0.3)
- Output layer (9 neurons, Softmax) 