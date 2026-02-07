# BananaDoc AI - Banana Leaf Nutrient Deficiency Detection

This project uses machine learning to detect nutrient deficiencies in banana plant leaves from images. It integrates with the BananaDoc Flutter application.

## Project Structure

```
BananaDoc_AI/
├── api/                    # API server for model predictions (RUNTIME)
│   └── banana_deficiency_api.py  # Flask API to serve model predictions
│
├── utils/                  # Utility functions (RUNTIME)
│   ├── image_preprocessor.py     # Image preprocessing utilities
│   ├── model_loader.py           # Model loading utilities
│   ├── deficiency_info.py        # Deficiency information provider
│   └── gemini_handler.py         # Gemini AI chatbot handler
│
├── models_runtime/         # Trained models used by the app (RUNTIME)
│   ├── banana_nutrient_model.h5
│   ├── banana_nutrient_model.keras
│   ├── banana_nutrient_model.tflite
│   ├── banana_mobile_model.tflite
│   └── class_mapping.txt
│
├── training/               # Model training scripts (DEVELOPMENT ONLY)
│   ├── train_model.py      # Script to train the model
│   ├── create_mobile_model.py
│   ├── compare_models.py
│   └── README.md           # Training documentation
│
├── data/                   # Runtime data storage
│   └── conversation_context.json
│
├── docs/                   # Documentation
│   ├── developer_guide.md
│   └── nutrient_deficiency_model_README.md
│
└── requirements.txt        # Python dependencies
```

### Directory Separation

- **Runtime Code** (`api/`, `utils/`, `models_runtime/`): Code and models needed for the app to run
- **Training Code** (`training/`): Scripts for developing and training new models
- **Documentation** (`docs/`): Project documentation

## Setup and Usage

### Installation

1. Install Python dependencies:

```bash
pip install -r requirements.txt
```

### Training the Model

⚠️ **Note**: Training scripts are in the `training/` directory. See `training/README.md` for detailed instructions.

1. Prepare your training dataset (see `training/README.md`)
2. Navigate to the training directory:

```bash
cd training
python train_model.py
```

After training, copy the models to `models_runtime/`:

```bash
cp banana_nutrient_model.* ../models_runtime/
cp class_mapping.txt ../models_runtime/
```

### Testing the Model

Test the model on individual images using the API (see "Running the API Server" below).

### Running the API Server

Start the Flask API server:

```bash
python run_api.py
```

Or directly:

```bash
cd api
python banana_deficiency_api.py
```

The server will start on `localhost:5002` (default) with the following endpoints:

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