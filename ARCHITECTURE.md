# BananaDoc Architecture

## Project Structure

```
BananaDoc/
├── lib/                          # Flutter application source code
│   ├── config/                   # Configuration files
│   ├── models/                   # Data models
│   ├── providers/                # State management
│   ├── screens/                  # UI screens
│   ├── services/                 # Business logic services
│   ├── widgets/                  # Reusable UI components
│   └── main.dart                 # Application entry point
│
├── BananaDoc_AI/                 # Python backend API
│   ├── api/                      # Flask API endpoints
│   │   └── banana_deficiency_api.py
│   ├── model/                    # ML model files and training scripts
│   │   ├── create_mobile_model.py
│   │   ├── train_model.py
│   │   └── [model files]
│   ├── utils/                    # Utility modules
│   │   ├── deficiency_info.py
│   │   ├── gemini_handler.py
│   │   ├── image_preprocessor.py
│   │   └── model_loader.py
│   ├── run_api.py                # API server entry point
│   └── requirements.txt           # Python dependencies
│
├── assets/                       # Static assets
│   ├── images/                   # Image assets
│   └── models/                   # TFLite model files (for offline mode)
│
└── scripts/                      # Utility scripts
    └── copy_models_to_assets.sh  # Model deployment script
```

## Architecture Layers

### Frontend (Flutter)
- **Presentation Layer**: Screens and widgets
- **Business Logic Layer**: Services (LLM, Gemini, TFLite, Nutrient Deficiency)
- **Data Layer**: Models and local storage
- **Configuration Layer**: Environment-based configuration

### Backend (Python Flask)
- **API Layer**: RESTful endpoints with authentication
- **ML Layer**: Model loading and inference
- **Utility Layer**: Image preprocessing, deficiency info, Gemini integration

## Key Components

### Services

1. **GeminiService** (`lib/services/gemini_service.dart`)
   - Handles direct Gemini API calls
   - Uses API key from environment variables
   - Secure header-based authentication

2. **NutrientDeficiencyService** (`lib/services/nutrient_deficiency_service.dart`)
   - Communicates with backend API
   - Handles image analysis requests
   - Manages API authentication

3. **TFLiteService** (`lib/services/tflite_service.dart`)
   - On-device model inference
   - Offline mode support
   - Mobile-optimized model loading

4. **LLMService** (`lib/services/llm_service.dart`)
   - Chat functionality
   - Context-aware responses
   - Multi-language support

### Backend API

**Endpoints:**
- `POST /predict` - Image analysis (requires auth)
- `POST /chat` - Chat queries (requires auth)
- `GET /health` - Health check (public)
- `GET /deficiencies` - List deficiencies (requires auth)
- `GET /deficiency/<type>` - Get deficiency details (requires auth)

**Security:**
- API key authentication via `X-API-Key` header
- Rate limiting (200/day, 50/hour)
- CORS restricted to allowed origins
- Input validation and sanitization

## Data Flow

### Online Mode
```
User → Flutter App → Backend API → ML Model → Response
                ↓
         Gemini API (for chat)
```

### Offline Mode
```
User → Flutter App → TFLite Model (on-device) → Response
```

## Configuration

### Environment Variables

**Backend** (`BananaDoc_AI/.env`):
- `GEMINI_API_KEY` - Google Gemini API key
- `BACKEND_API_KEY` - Backend authentication key
- `HOST` - Server host (default: 127.0.0.1)
- `PORT` - Server port (default: 5002)
- `ALLOWED_ORIGINS` - CORS allowed origins
- `REQUIRE_AUTH` - Enable/disable authentication
- `FLASK_ENV` - Environment (development/production)

**Flutter** (build-time via `--dart-define`):
- `GEMINI_API_KEY` - Google Gemini API key
- `API_BASE_URL` - Backend API URL
- `BACKEND_API_KEY` - Backend authentication key

## Best Practices

1. **Security**
   - All API keys in environment variables
   - Authentication required on protected endpoints
   - Rate limiting enabled
   - Input validation on all endpoints

2. **Code Organization**
   - Separation of concerns (services, models, screens)
   - Environment-based configuration
   - Reusable components

3. **Error Handling**
   - Generic error messages in production
   - Proper exception handling
   - User-friendly error messages

4. **Performance**
   - Offline mode for mobile devices
   - Optimized TFLite models
   - Efficient image processing

## Development Workflow

1. **Backend Development**
   ```bash
   cd BananaDoc_AI
   python run_api.py
   ```

2. **Flutter Development**
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=... \
              --dart-define=API_BASE_URL=... \
              --dart-define=BACKEND_API_KEY=...
   ```

3. **Model Updates**
   ```bash
   # Create mobile model
   cd BananaDoc_AI/model
   ./create_mobile_model.sh
   
   # Copy to assets
   cd ../..
   ./copy_models_to_assets.sh
   ```

