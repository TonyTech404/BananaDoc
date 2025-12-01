# Farmer Community Forum - Setup Guide

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `bananadoc` (or your preferred name)
4. Enable Google Analytics (optional)
5. Create project

### 2. Enable Firestore Database

1. In Firebase Console, go to "Build" > "Firestore Database"
2. Click "Create database"
3. Choose "Start in production mode" (we'll set rules later)
4. Select your preferred location (e.g., asia-southeast1)
5. Click "Enable"

### 3. Setup Firebase Admin SDK (Backend)

1. In Firebase Console, go to Project Settings (gear icon)
2. Go to "Service accounts" tab
3. Click "Generate new private key"
4. Download the JSON file
5. Save it as `firebase_config.json` in `BananaDoc_AI/` directory
6. **IMPORTANT**: Add `firebase_config.json` to `.gitignore`

### 4. Setup Firebase Storage

1. In Firebase Console, go to "Build" > "Storage"
2. Click "Get started"
3. Accept the default security rules
4. Choose same location as Firestore
5. Click "Done"

### 5. Setup Firebase Authentication (Flutter)

1. In Firebase Console, go to "Build" > "Authentication"
2. Click "Get started"
3. Enable "Email/Password" sign-in method
4. (Optional) Enable "Google" sign-in for easier registration

### 6. Firebase for Flutter

#### Android Setup
1. In Firebase Console, add Android app
2. Enter package name: `com.example.bananadoc` (check `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it in `android/app/` directory

#### iOS Setup
1. In Firebase Console, add iOS app
2. Enter bundle ID (check `ios/Runner.xcodeproj/project.pbxproj`)
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

### 7. Environment Variables

Add to your `.env` file:

```env
# Existing variables...
GEMINI_API_KEY=your_existing_key
BACKEND_API_KEY=your_existing_key
API_BASE_URL=http://127.0.0.1:5002

# Forum-specific variables
FIREBASE_CONFIG_PATH=./firebase_config.json
JWT_SECRET_KEY=your_random_secret_key_here_change_in_production
JWT_EXPIRATION_HOURS=24
```

## Firestore Database Structure

### Collections

#### users
```
users/{userId}
  - username: string
  - email: string
  - profilePicture: string (URL)
  - location: string
  - farmSize: string
  - bio: string
  - role: string (farmer|expert|admin)
  - reputation: number
  - createdAt: timestamp
  - updatedAt: timestamp
```

#### posts
```
posts/{postId}
  - authorId: string (ref to users)
  - title: string
  - content: string
  - images: array of strings (URLs)
  - category: string (question|discussion|tip|problem)
  - deficiencyType: string (optional)
  - tags: array of strings
  - location: string
  - likes: number
  - views: number
  - commentCount: number
  - createdAt: timestamp
  - updatedAt: timestamp
  - isPinned: boolean
  - isSolved: boolean
```

#### comments
```
comments/{commentId}
  - postId: string (ref to posts)
  - authorId: string (ref to users)
  - content: string
  - images: array of strings (URLs)
  - likes: number
  - createdAt: timestamp
  - isMarkedAsAnswer: boolean
```

#### likes
```
likes/{likeId}
  - userId: string (ref to users)
  - targetId: string (postId or commentId)
  - targetType: string (post|comment)
  - createdAt: timestamp
```

## Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isOwner(userId);
    }
    
    // Posts collection
    match /posts/{postId} {
      allow read: if true; // Public reading
      allow create: if isSignedIn();
      allow update: if isSignedIn() && isOwner(resource.data.authorId);
      allow delete: if isSignedIn() && isOwner(resource.data.authorId);
    }
    
    // Comments collection
    match /comments/{commentId} {
      allow read: if true; // Public reading
      allow create: if isSignedIn();
      allow update: if isSignedIn() && isOwner(resource.data.authorId);
      allow delete: if isSignedIn() && isOwner(resource.data.authorId);
    }
    
    // Likes collection
    match /likes/{likeId} {
      allow read: if true;
      allow create: if isSignedIn();
      allow delete: if isSignedIn() && isOwner(resource.data.userId);
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /forum/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null
                   && request.resource.size < 5 * 1024 * 1024 // 5MB max
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Installation

### Backend
```bash
cd BananaDoc_AI
pip install -r requirements.txt
```

### Flutter
```bash
flutter pub get
```

## Running the Application

### Backend
```bash
cd BananaDoc_AI
python run_api.py
```

### Flutter
```bash
flutter run
```

## Testing Firebase Connection

Test the backend Firebase connection:
```bash
cd BananaDoc_AI
python -c "from utils.firebase_service import FirebaseService; fs = FirebaseService(); print('Firebase connected successfully!')"
```

## Troubleshooting

### "Default app already exists"
- Make sure you're only initializing Firebase once
- Check if `firebase_admin.initialize_app()` is called multiple times

### "Permission denied" errors
- Verify Firestore security rules are set correctly
- Check if user is authenticated before making requests
- Ensure service account has proper permissions

### "Module not found" errors
- Run `pip install -r requirements.txt`
- Make sure you're in the correct Python environment

## Next Steps

1. ✅ Complete Firebase setup following this guide
2. Create forum models in backend
3. Implement API endpoints
4. Create Flutter UI
5. Test end-to-end functionality
