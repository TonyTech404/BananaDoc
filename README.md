# BananaDoc - AI-Powered Banana Leaf Deficiency Detection

A complete solution for detecting and analyzing banana leaf deficiencies using AI and machine learning. This monorepo contains both the Flutter mobile application and Python backend API.

## 📁 Repository Structure

```
BananaDoc/
├── mobile/              # Flutter mobile application
├── backend/             # Python API backend
└── docs/                # Shared documentation
```

## 🚀 Quick Start

### Prerequisites

- **For Mobile Development:**
  - Flutter SDK (3.0+)
  - Android Studio / Xcode
  - Dart SDK

- **For Backend Development:**
  - Python 3.8+
  - pip
  - Virtual environment (recommended)

### Mobile App Setup

```bash
cd mobile
flutter pub get
flutter run
```

For detailed mobile setup instructions, see [mobile/README.md](mobile/README.md)

### Backend API Setup

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python run_api.py
```

For detailed backend setup instructions, see [backend/README.md](backend/README.md)

## ⚙️ Configuration

### Mobile App Configuration

The mobile app requires the following environment variables:

- `GEMINI_API_KEY` - Google Gemini API key for AI chat features
- `API_BASE_URL` - Backend API URL (default: `http://localhost:5002`)
- `BACKEND_API_KEY` - Backend API authentication key

Run with environment variables:
```bash
cd mobile
flutter run --dart-define=GEMINI_API_KEY=your_key \
            --dart-define=API_BASE_URL=http://localhost:5002
```

### Backend Configuration

Create a `.env` file in the backend directory:
```bash
GEMINI_API_KEY=your_gemini_api_key
PORT=5002
```

## 🏗️ Architecture

### System Overview

```
┌─────────────────┐           ┌─────────────────┐
│                 │           │                 │
│  Flutter App    │◄─────────►│  Python API     │
│  (mobile/)      │    API    │  (backend/)     │
│                 │  Calls    │                 │
└────────┬────────┘           └────────┬────────┘
         │                             │
         │                             │
         ▼                             ▼
┌─────────────────┐           ┌─────────────────┐
│                 │           │                 │
│ TFLite Model    │           │ TensorFlow      │
│ (On-Device)     │           │ ML Model        │
│                 │           │                 │
└─────────────────┘           └─────────────────┘
```

### Key Features

- **Mobile App (Flutter)**
  - Cross-platform (iOS & Android)
  - On-device ML inference with TFLite
  - Offline mode support
  - AI-powered chat with Gemini
  - Image capture and analysis

- **Backend API (Python)**
  - Flask REST API
  - TensorFlow model serving
  - Model training pipeline
  - Gemini API integration
  - Docker support

## 📚 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Mobile Model Setup](docs/MOBILE_MODEL_SETUP.md)
- [Project Structure](docs/PROJECT_STRUCTURE.md)
- [Backend Developer Guide](backend/docs/developer_guide.md)
- [Nutrient Deficiency Model](backend/docs/nutrient_deficiency_model_README.md)

## 🔧 Development Workflow

### Working on Mobile

1. Navigate to mobile directory: `cd mobile`
2. Make changes to Dart/Flutter code
3. Test on emulator/device: `flutter run`
4. Hot reload: Press `r` in terminal
5. Hot restart: Press `R` in terminal

### Working on Backend

1. Navigate to backend directory: `cd backend`
2. Activate virtual environment: `source venv/bin/activate`
3. Make changes to Python code
4. Restart server: `python run_api.py`
5. Test API endpoints: `curl http://localhost:5002/health`

### Model Development

1. Navigate to training directory: `cd backend/training`
2. Prepare your dataset
3. Train model: `python train_model.py`
4. Convert to mobile format: `python create_mobile_model.py`
5. Copy to mobile assets: `cd ../../mobile && ./copy_models_to_assets.sh`

## 🐳 Docker Support

Run the backend with Docker:

```bash
cd backend
docker-compose up
```

## 🧪 Testing

### Mobile Tests
```bash
cd mobile
flutter test
```

### Backend Tests
```bash
cd backend
python -m pytest
```

## 📱 Building for Production

### Android APK
```bash
cd mobile
flutter build apk --release
```

### iOS IPA
```bash
cd mobile
flutter build ios --release
```

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📄 License

[Your License Here]

## 🆘 Support

For issues and questions:
- Mobile issues: Check [mobile/README.md](mobile/README.md)
- Backend issues: Check [backend/README.md](backend/README.md)
- General questions: Create an issue on GitHub

## 👥 Team

Developed by **TEAMBA - CS3**

---

**Last Updated:** February 22, 2026
