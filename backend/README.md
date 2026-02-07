# BananaDoc Backend API

Python Flask API for banana leaf deficiency detection using TensorFlow/Keras ML models.

## 🎯 Overview

This backend provides:
- REST API for image analysis
- TensorFlow model serving
- Gemini AI chat integration
- Model training pipeline
- Docker deployment support

## 🚀 Quick Start

### Prerequisites

- Python 3.8 or later
- pip
- Virtual environment (recommended)
- (Optional) Docker & Docker Compose

### Installation

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   ```bash
   # Create .env file with your configuration
   echo "GEMINI_API_KEY=your_key_here" > .env
   echo "PORT=5002" >> .env
   ```

5. **Run the API server**
   ```bash
   python run_api.py
   ```

The API will start on `http://localhost:5002`

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```bash
# Gemini API Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Server Configuration
PORT=5002
HOST=0.0.0.0
DEBUG=True

# Model Configuration
MODEL_PATH=models_runtime/banana_mobile_model.tflite
CLASS_MAPPING_PATH=models_runtime/mobile_class_mapping.txt
```

## 🏗️ Project Structure

```
backend/
├── api/                          # API endpoints
│   ├── banana_deficiency_api.py  # Main prediction API
│   └── chat_server.py            # Chat/conversation API
├── utils/                        # Utility modules
│   ├── deficiency_info.py        # Deficiency information
│   ├── gemini_handler.py         # Gemini API integration
│   ├── image_preprocessor.py     # Image preprocessing
│   └── model_loader.py           # Model loading utilities
├── models_runtime/               # Production ML models
│   ├── banana_mobile_model.tflite
│   ├── mobile_class_mapping.txt
│   └── model_metadata.json
├── training/                     # Model training scripts
│   ├── train_model.py
│   ├── create_mobile_model.py
│   ├── finetune_mobile_model.py
│   └── convert_to_tflite.py
├── data/                         # Runtime data
│   └── conversation_context.json
├── docs/                         # Documentation
├── requirements.txt              # Python dependencies
├── run_api.py                    # API entry point
├── Dockerfile                    # Docker configuration
└── docker-compose.yml            # Docker Compose setup
```

## 📡 API Endpoints

### Health Check
```
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-02-07T10:00:00Z"
}
```

### Predict Deficiency
```
POST /predict
Content-Type: multipart/form-data
```

**Request:**
- `image`: Image file (JPEG/PNG)

**Response:**
```json
{
  "prediction": "Nitrogen Deficiency",
  "confidence": 0.92,
  "recommendations": [...],
  "timestamp": "2026-02-07T10:00:00Z"
}
```

### Chat / AI Analysis
```
POST /chat
Content-Type: application/json
```

## 🐳 Docker Deployment

### Using Docker Compose (Recommended)

```bash
# Build and run
docker-compose up --build

# Run in detached mode
docker-compose up -d

# Stop
docker-compose down
```

## 🤖 Model Training

### Training a New Model

1. Prepare your dataset in `training/data/`
2. Run training script:
   ```bash
   cd training
   python train_model.py
   ```
3. Create mobile-optimized model:
   ```bash
   python create_mobile_model.py
   ```

See [training/README.md](training/README.md) for detailed instructions.

## 🧪 Testing

```bash
# Health check
curl http://localhost:5002/health

# Predict with image
curl -X POST http://localhost:5002/predict \
  -F "image=@path/to/image.jpg"
```

## 📦 Dependencies

Key packages:
- `flask` - Web framework
- `tensorflow` - ML framework
- `pillow` - Image processing
- `google-generativeai` - Gemini API

See [requirements.txt](requirements.txt) for complete list.

## 🔍 Troubleshooting

**Issue: Port already in use**
```bash
# Change port in .env or kill process
lsof -ti:5002 | xargs kill -9
```

**Issue: Model not found**
```bash
# Verify model files exist in models_runtime/
ls -la models_runtime/
```

## 📄 License

[Your License Here]

---

**Framework:** Flask  
**Language:** Python  
**ML Framework:** TensorFlow/Keras  
**AI Integration:** Google Gemini
