# BananaDoc Mobile App

Flutter mobile application for AI-powered banana leaf deficiency detection.

## 📱 Features

- **Image Analysis**: Capture or upload banana leaf images for instant analysis
- **Offline Mode**: On-device TFLite model for offline deficiency detection
- **AI Chat**: Conversational interface powered by Google Gemini
- **History**: Track previous analyses and recommendations
- **Multi-language Support**: Localization support for multiple languages
- **Cross-platform**: Runs on iOS and Android

## 🚀 Setup

### Prerequisites

- Flutter SDK 3.0 or later
- Dart SDK 2.19 or later
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Navigate to mobile directory**
   ```bash
   cd mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Copy ML models to assets** (if not already present)
   ```bash
   ./copy_models_to_assets.sh
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Environment Variables

The app uses compile-time environment variables set via `--dart-define`:

#### Required for Production:
- `GEMINI_API_KEY` - Your Google Gemini API key

#### Optional:
- `API_BASE_URL` - Backend API URL (default: `http://localhost:5002`)
- `BACKEND_API_KEY` - Backend authentication key

### Running with Configuration

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=your_gemini_key \
  --dart-define=API_BASE_URL=http://your-backend-url:5002 \
  --dart-define=BACKEND_API_KEY=your_backend_key
```

### Configuration File

Edit [lib/config/app_config.dart](lib/config/app_config.dart) to set default values:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:5002', // Change this default
);
```

## 🏗️ Project Structure

```
mobile/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/                   # App configuration
│   ├── models/                   # Data models
│   ├── providers/                # State management (Provider)
│   ├── screens/                  # UI screens
│   ├── services/                 # API & business logic
│   ├── theme/                    # App theming
│   └── widgets/                  # Reusable widgets
├── android/                      # Android-specific code
├── ios/                          # iOS-specific code
├── assets/
│   ├── images/                   # Image assets
│   └── models/                   # TFLite models
├── test/                         # Unit & widget tests
└── pubspec.yaml                  # Dependencies
```

## 🔧 Development

### Running on Emulator/Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS simulator
flutter run -d iPhone
```

### Hot Reload

While the app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debugging

```bash
# Run in debug mode (default)
flutter run

# Run in profile mode (performance profiling)
flutter run --profile

# Run in release mode
flutter run --release
```

## 📦 Building

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build IPA
flutter build ios --release

# Output needs to be signed via Xcode
# Open ios/Runner.xcworkspace in Xcode
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 📱 Platform-Specific Setup

### Android

**Minimum SDK:** 26 (Android 8.0)

Update [android/app/build.gradle.kts](android/app/build.gradle.kts):
```kotlin
defaultConfig {
    minSdk = 26
    targetSdk = 34
}
```

**Permissions:**
- Camera (for image capture)
- Storage (for image selection)
- Internet (for API calls)

### iOS

**Minimum iOS Version:** 12.0

Update [ios/Podfile](ios/Podfile):
```ruby
platform :ios, '12.0'
```

**Permissions in Info.plist:**
- Camera usage description
- Photo library usage description

## 📚 Key Dependencies

- `provider` - State management
- `http` - HTTP requests
- `image_picker` - Image capture/selection
- `tflite_flutter` - On-device ML inference
- `google_fonts` - Custom fonts
- `flutter_markdown` - Markdown rendering
- `shared_preferences` - Local storage

See [pubspec.yaml](pubspec.yaml) for complete list.

## 🔍 Troubleshooting

### Build Errors

**Issue: minSdkVersion error**
```
Solution: Ensure minSdk is set to 26 in android/app/build.gradle.kts
```

**Issue: TFLite plugin error**
```bash
Solution: 
flutter clean
flutter pub get
cd android && ./gradlew clean
cd .. && flutter run
```

### Runtime Errors

**Issue: Model not found**
```bash
Solution: Run ./copy_models_to_assets.sh and rebuild
```

**Issue: API connection failed**
```
Solution: Check API_BASE_URL configuration and ensure backend is running
```

## 🌐 API Integration

The app connects to the Python backend API for:
- Advanced deficiency analysis
- Chat/conversation context
- Model predictions (when online)

**Default Backend URL:** `http://localhost:5002`

**API Endpoints Used:**
- `GET /health` - Health check
- `POST /predict` - Image analysis
- `POST /chat` - AI chat
- `POST /clear-context` - Clear chat history

See [backend documentation](../backend/README.md) for API details.

## 📄 License

[Your License Here]

## 🆘 Support

For issues:
1. Check troubleshooting section above
2. Review [docs/MOBILE_MODEL_SETUP.md](../docs/MOBILE_MODEL_SETUP.md)
3. Create an issue on GitHub

---

**Platform:** Flutter  
**Language:** Dart  
**State Management:** Provider  
**ML Framework:** TFLite
