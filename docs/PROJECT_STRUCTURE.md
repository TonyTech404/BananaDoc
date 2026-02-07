# BananaDoc Project Structure

## Overview

This document describes the clean, organized structure of the BananaDoc project with clear separation between runtime code and development/training code.

## Directory Structure

```
BananaDoc/
├── BananaDoc_AI/              # Python backend API
│   ├── api/                   # API server (RUNTIME)
│   │   └── banana_deficiency_api.py
│   │
│   ├── utils/                 # Utility modules (RUNTIME)
│   │   ├── image_preprocessor.py
│   │   ├── model_loader.py
│   │   ├── deficiency_info.py
│   │   └── gemini_handler.py  # Gemini AI integration
│   │
│   ├── models_runtime/         # Trained models (RUNTIME)
│   │   ├── banana_nutrient_model.h5
│   │   ├── banana_nutrient_model.keras
│   │   ├── banana_nutrient_model.tflite
│   │   ├── banana_mobile_model.tflite
│   │   └── class_mapping.txt
│   │
│   ├── training/              # Training scripts (DEVELOPMENT)
│   │   ├── train_model.py
│   │   ├── create_mobile_model.py
│   │   ├── compare_models.py
│   │   └── README.md
│   │
│   ├── data/                  # Runtime data storage
│   │   └── conversation_context.json
│   │
│   ├── docs/                  # Documentation
│   │   ├── developer_guide.md
│   │   └── nutrient_deficiency_model_README.md
│   │
│   ├── requirements.txt       # Python dependencies
│   └── run_api.py            # API server launcher
│
├── lib/                       # Flutter app source code
│   ├── config/                # App configuration
│   ├── services/              # Business logic services
│   ├── screens/               # UI screens
│   ├── models/                # Data models
│   └── widgets/               # Reusable widgets
│
├── assets/                    # App assets
│   ├── images/                # Image assets
│   └── models/                # Mobile model files
│
└── .gitignore                # Git ignore rules
```

## Key Separations

### 1. Runtime vs Development

- **Runtime Code** (`api/`, `utils/`, `models_runtime/`): 
  - Code and models needed for the app to run
  - Used by the API server and Flutter app
  - Should be production-ready

- **Training Code** (`training/`):
  - Scripts for developing and training models
  - Not needed for app runtime
  - Used only when retraining models

### 2. Model Files

- **Runtime Models** (`models_runtime/`):
  - Production-ready trained models
  - Used by the API and mobile app
  - Tracked in git (with exceptions)

- **Training Artifacts** (`training/`):
  - Training history plots
  - Development model checkpoints
  - Ignored by git

### 3. Data Storage

- **Runtime Data** (`data/`):
  - Conversation context
  - User session data
  - Created at runtime

## File Organization Rules

1. **Never mix runtime and training code**
2. **Models go to `models_runtime/` after training**
3. **Training scripts stay in `training/`**
4. **Documentation in `docs/`**
5. **Large datasets excluded from git**

## Benefits of This Structure

✅ **Clear separation** - Easy to identify what's needed for runtime
✅ **Cleaner repository** - Training code doesn't clutter runtime
✅ **Better organization** - Related files grouped together
✅ **Easier deployment** - Only runtime code needs to be deployed
✅ **Simpler maintenance** - Clear where to find and update files

## Migration Notes

- Old `model/` directory has been split into:
  - `models_runtime/` - Runtime models
  - `training/` - Training scripts
- Training dataset removed (was 269MB)
- All paths updated to reflect new structure

