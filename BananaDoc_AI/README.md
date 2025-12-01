# BananaDoc AI - Backend Services

This backend provides AI-powered banana leaf nutrient deficiency detection and a farmer community forum.

## Features

### 1. Nutrient Deficiency Detection
Machine learning model to detect nutrient deficiencies in banana plant leaves from images.

### 2. Farmer Community Forum (NEW! 🎉)
Complete RESTful API for a farmer community forum with:
- User authentication (JWT)
- Posts with categories and tags
- Comments system
- Like/unlike functionality
- Search capabilities
- Firebase Firestore integration

## Project Structure

```
BananaDoc_AI/
├── api/                    # API servers (RUNTIME)
│   ├── banana_deficiency_api.py  # Main Flask API
│   └── forum_api.py              # Forum endpoints (NEW)
│
├── models/                 # Data models (NEW)
│   ├── forum_user.py
│   ├── forum_post.py
│   └── forum_comment.py
│
├── utils/                  # Utility functions (RUNTIME)
│   ├── image_preprocessor.py     # Image preprocessing
│   ├── model_loader.py           # ML model loading
│   ├── deficiency_info.py        # Deficiency information
│   ├── gemini_handler.py         # Gemini AI chatbot
│   ├── firebase_service.py       # Firebase operations (NEW)
│   └── auth_service.py           # JWT authentication (NEW)
│
├── models_runtime/         # Trained ML models (RUNTIME)
│   ├── banana_nutrient_model.h5
│   ├── banana_nutrient_model.keras
│   ├── banana_nutrient_model.tflite
│   ├── banana_mobile_model.tflite
│   └── class_mapping.txt
│
├── training/               # Model training scripts (DEVELOPMENT)
│   ├── train_model.py
│   ├── create_mobile_model.py
│   ├── compare_models.py
│   └── README.md
│
├── data/                   # Runtime data storage
│   └── conversation_context.json
│
├── docs/                   # Documentation
│   ├── developer_guide.md
│   ├── nutrient_deficiency_model_README.md
│   ├── FORUM_SETUP.md            # Forum setup guide (NEW)
│   └── FORUM_API.md              # Forum API docs (NEW)
│
├── firebase_config_example.json  # Firebase config template (NEW)
└── requirements.txt              # Python dependencies
```

---

## 🚀 Quick Start

### 1. Installation

Install Python dependencies:

```bash
pip install -r requirements.txt
```

### 2. Environment Setup

Copy the example environment file and configure:

```bash
cp ../.env.example ../.env
```

Edit `.env` and add your keys:
```env
GEMINI_API_KEY=your_gemini_api_key
JWT_SECRET_KEY=your_random_secret_key
FIREBASE_CONFIG_PATH=./BananaDoc_AI/firebase_config.json
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
```

### 3. Firebase Setup (for Forum)

**Required for forum functionality:**

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Firestore Database
3. Enable Firebase Storage
4. Download service account credentials
5. Save as `firebase_config.json` in this directory

**Detailed instructions:** See `docs/FORUM_SETUP.md`

### 4. Run the Server

```bash
python run_api.py
```

Server runs on `http://127.0.0.1:5002`

---

## 📡 API Endpoints

### Deficiency Detection API

- **POST /predict** - Analyze banana leaf image
- **POST /chat** - Chat with AI assistant
- **GET /health** - Health check
- **GET /deficiencies** - List all deficiencies
- **GET /deficiency/<type>** - Get deficiency info

### Forum API (NEW)

#### Authentication
- **POST /api/forum/auth/register** - Register new user
- **POST /api/forum/auth/login** - User login

#### Users
- **GET /api/forum/users/{userId}** - Get user profile
- **PUT /api/forum/users/{userId}** - Update profile

#### Posts
- **GET /api/forum/posts** - Get posts (with filtering)
- **POST /api/forum/posts** - Create post
- **GET /api/forum/posts/{postId}** - Get single post
- **PUT /api/forum/posts/{postId}** - Update post
- **DELETE /api/forum/posts/{postId}** - Delete post
- **POST /api/forum/posts/{postId}/solve** - Mark as solved

#### Comments
- **GET /api/forum/posts/{postId}/comments** - Get comments
- **POST /api/forum/posts/{postId}/comments** - Create comment
- **PUT /api/forum/comments/{commentId}** - Update comment
- **DELETE /api/forum/comments/{commentId}** - Delete comment

#### Interactions
- **POST /api/forum/posts/{postId}/like** - Like/unlike post
- **POST /api/forum/comments/{commentId}/like** - Like/unlike comment

#### Search
- **GET /api/forum/search** - Search posts

**Complete API documentation:** See `docs/FORUM_API.md`

---

## 🧪 Testing

### Test Deficiency Detection
```bash
curl -X POST http://127.0.0.1:5002/predict \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_backend_api_key" \
  -d '{"image": "base64_encoded_image"}'
```

### Test Forum Registration
```bash
curl -X POST http://127.0.0.1:5002/api/forum/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "test_user",
    "email": "test@example.com",
    "password": "password123"
  }'
```

---

## 📚 Documentation

- **Forum Setup Guide:** `docs/FORUM_SETUP.md`
- **Forum API Reference:** `docs/FORUM_API.md`
- **Developer Guide:** `docs/developer_guide.md`
- **Model Training:** `training/README.md`

---

## 🔐 Security

- JWT-based authentication
- Password hashing with bcrypt
- Rate limiting (200/day, 50/hour)
- CORS configuration
- API key authentication for deficiency detection
- Firebase security rules

---

## 🎯 Machine Learning Model

### Dataset
Images of banana leaves showing deficiencies in 8 nutrients:
- Boron, Calcium, Iron, Potassium
- Manganese, Magnesium, Sulphur, Zinc
- Plus healthy leaves (9 classes total)

### Model Architecture
Transfer learning based on MobileNetV2:
- MobileNetV2 base (frozen)
- Global Average Pooling
- Dense (1024, ReLU) + Dropout (0.5)
- Dense (512, ReLU) + Dropout (0.3)
- Output (9, Softmax)

### Training
See `training/README.md` for detailed instructions.

---

## 🔄 Integration with Flutter

The backend integrates with the BananaDoc Flutter app through:

**Existing Services:**
- `lib/services/nutrient_deficiency_service.dart`
- `lib/screens/deficiency_detection_screen.dart`

**New Services (To be implemented):**
- `lib/services/forum/forum_service.dart`
- `lib/screens/forum/forum_home_screen.dart`

---

## 🌟 New Features in This Release

### Farmer Community Forum Backend
- ✅ User authentication system
- ✅ Post creation and management
- ✅ Comment system
- ✅ Like/unlike functionality
- ✅ Search capabilities
- ✅ Category filtering
- ✅ Firebase Firestore integration
- ✅ JWT token authentication
- ✅ Role-based access control
- ✅ Comprehensive API documentation

### Git Branch
Feature branch: `feature/farmer-community-forum`

Commits:
1. Firebase setup and dependencies
2. Forum data models and services
3. Forum API endpoints implementation

---

## 📝 License

This project is part of the BananaDoc application for banana leaf nutrient deficiency detection and farmer community support. 