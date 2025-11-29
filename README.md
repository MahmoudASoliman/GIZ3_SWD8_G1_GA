# Blood Donation App 🩸

A Flutter-based mobile application that connects blood donors with hospitals in need of blood donations. The app facilitates real-time communication, donation tracking, and efficient blood request management.

---

## 📋 Table of Contents

- [Features](#features)
- [System Requirements](#system-requirements)
- [Installation Steps](#installation-steps)
- [Configuration Instructions](#configuration-instructions)
- [Execution Guide](#execution-guide)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)

---

## ✨ Features

### For Donors:
- 🔐 Secure authentication and profile management
- 🔍 Browse and filter blood requests by location and blood type
- 🤝 Accept and track donation offers
- 📱 Real-time push notifications for nearby blood requests
- 📊 View donation history and status

### For Hospitals:
- 🏥 Create and manage blood requests
- 📢 Broadcast urgent blood needs to matching donors
- ✅ Accept/reject donation offers
- 🔐 OTP-based donation verification system
- 📈 Track request status and donation offers

### General:
- 🌐 Real-time notifications via Firebase Cloud Messaging
- 🗺️ Location-based request filtering
- 🔒 Secure data handling with Supabase
- 📱 Beautiful, intuitive UI with modern design patterns
- 🌍 Multi-language support (English/Arabic)

---

## 💻 System Requirements

### Hardware Requirements:
- **Minimum**: 4GB RAM, 2GB free storage
- **Recommended**: 8GB RAM, 5GB free storage
- Android device (5.0+) or iOS device (11.0+) for testing

### Software Dependencies:

#### Development Environment:
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Xcode** (for iOS development, macOS only)
- **Git**: For version control

#### Backend Services:
- **Supabase Account**: For authentication and database
- **Firebase Project**: For push notifications (FCM)
- **Google Cloud Console Account**: For Firebase setup

#### Required Tools:
- Node.js (for Firebase CLI)
- Android SDK (API Level 21+)
- CocoaPods (for iOS dependencies)

---

## 📥 Installation Steps

### 1. Install Flutter

#### Windows:
```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter doctor
```

#### macOS/Linux:
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Clone the Repository

```bash
git clone <repository-url>
cd GIZ3_SWD8_G1_GA-main
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Install Additional Tools

#### For Android:
```bash
# Android Studio will prompt you to install Android SDK
# Or install via command line:
sdkmanager "platform-tools" "platforms;android-33"
```

#### For iOS (macOS only):
```bash
cd ios
pod install
cd ..
```

---

## ⚙️ Configuration Instructions

### 1. Supabase Setup

1. **Create Supabase Project**:
   - Visit [Supabase](https://supabase.com/)
   - Create a new project
   - Note your Project URL and API Key

2. **Configure Database**:
   ```bash
   # Run migrations (if using Supabase CLI)
   cd supabase
   supabase db push
   ```

3. **Set Environment Variables**:
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

4. **Update Configuration**:
   Update `lib/core/constants/api_constants.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY';
   ```

### 2. Firebase Setup

1. **Create Firebase Project**:
   - Visit [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Cloud Messaging

2. **Configure Android**:
   ```bash
   # Download google-services.json from Firebase Console
   # Place it in: android/app/google-services.json
   ```

3. **Configure iOS** (macOS only):
   ```bash
   # Download GoogleService-Info.plist from Firebase Console
   # Place it in: ios/Runner/GoogleService-Info.plist
   ```

4. **Run FlutterFire CLI**:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

### 3. App Icon & Name Configuration

The app is already configured with:
- **App Name**: "Blood Donation"
- **App Icon**: `assets/app_icon.png`

To regenerate icons (if needed):
```bash
flutter pub run flutter_launcher_icons
```

---

## 🚀 Execution Guide

### Running Locally

#### 1. Start an Emulator/Device

**Android Emulator**:
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>
```

**iOS Simulator** (macOS only):
```bash
open -a Simulator
```

**Physical Device**:
- Enable USB Debugging (Android)
- Trust the computer (iOS)
- Connect via USB

#### 2. Run the Application

**Debug Mode**:
```bash
flutter run
```

**Release Mode**:
```bash
flutter run --release
```

**Specific Device**:
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Hot Reload & Restart

While the app is running:
- Press `r` for Hot Reload
- Press `R` for Hot Restart
- Press `q` to Quit

---

## 📦 Building Executables

### Android APK

**Debug APK**:
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

**Release APK**:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Split APKs by ABI** (smaller file size):
```bash
flutter build apk --split-per-abi
```

### Android App Bundle (AAB)

For Google Play Store:
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS App (macOS only)

```bash
flutter build ios --release
# Then archive in Xcode for App Store submission
```

### Installation from APK

```bash
# Install via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or transfer APK to device and install manually
```

---

## 📁 Project Structure

```
lib/
├── core/                       # Core functionality
│   ├── constants/             # App-wide constants
│   ├── di/                    # Dependency injection
│   ├── router/                # Navigation/routing
│   ├── services/              # App services (notifications, etc.)
│   ├── utils/                 # Utility functions
│   └── widgets/               # Reusable widgets
├── features/                   # Feature modules
│   ├── auth/                  # Authentication
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── donor/                 # Donor features
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── hospital/              # Hospital features
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── donation/              # Donation management
│   └── notifications/         # Notification handling
└── main.dart                  # App entry point

assets/                         # Static assets
├── app_icon.png               # App icon
├── Drop.png                   # UI assets
└── ...

supabase/                       # Supabase configuration
├── functions/                 # Edge functions
└── migrations/                # Database migrations
```

---

## 🛠️ Technologies Used

### Frontend:
- **Flutter**: 3.x - UI framework
- **Dart**: 3.x - Programming language
- **flutter_bloc**: State management
- **go_router**: Navigation
- **injectable/get_it**: Dependency injection

### Backend:
- **Supabase**: Authentication, Database, Real-time
- **PostgreSQL**: Database (via Supabase)
- **Firebase Cloud Messaging**: Push notifications

### UI/UX:
- **Material Design**: UI components
- **Custom Widgets**: Reusable components
- **flutter_launcher_icons**: App icon generation

### Network:
- **dio**: HTTP client
- **dartz**: Functional programming

### Storage:
- **shared_preferences**: Local storage

---

## 📖 API Documentation

### Authentication Endpoints

#### Register User
```dart
POST /auth/v1/signup
Body: {
  "email": "user@example.com",
  "password": "password123",
  "data": {
    "user_type": "donor" | "hospital"
  }
}
```

#### Login
```dart
POST /auth/v1/token?grant_type=password
Body: {
  "email": "user@example.com",
  "password": "password123"
}
```

### Donor Endpoints

#### Get Blood Requests
```dart
GET /rest/v1/blood_requests?status=eq.pending
```

#### Create Donation Offer
```dart
POST /rest/v1/donations
Body: {
  "request_id": "uuid",
  "donor_id": "uuid",
  "status": "pending"
}
```

### Hospital Endpoints

#### Create Blood Request
```dart
POST /rest/v1/blood_requests
Body: {
  "patient_name": "string",
  "blood_group": "A+",
  "hospital_id": "uuid",
  "urgency_level": "high",
  ...
}
```

#### Accept/Reject Donation
```dart
PATCH /rest/v1/donations?id=eq.<donation_id>
Body: {
  "status": "accepted" | "rejected"
}
```

### Notifications

Firebase Cloud Messaging is used for push notifications. The Supabase Edge Function handles notification sending.

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues
```bash
flutter doctor -v
# Follow the recommendations to fix issues
```

#### 2. Dependency Conflicts
```bash
flutter clean
flutter pub get
```

#### 3. Build Errors
```bash
# Android
cd android && ./gradlew clean
cd ..

# iOS
cd ios && pod deintegrate && pod install
cd ..
```

#### 4. Hot Reload Not Working
```bash
# Restart the app
flutter run
```

#### 5. Firebase Configuration Issues
```bash
# Reconfigure Firebase
flutterfire configure
```

#### 6. Supabase Connection Issues
- Check internet connection
- Verify Supabase URL and API keys
- Check Supabase project status

### Debug Mode

Enable verbose logging:
```bash
flutter run --verbose
```

Check logs:
```bash
# Android
adb logcat

# iOS
open Console.app
```

---

## 📞 Support

For issues or questions:
- Create an issue in the repository
- Contact the development team
- Check existing issues for solutions

---

## 📄 License

This project is developed as part of the GIZ Software Development Program.

---

## 👥 Contributors

- Development Team: GIZ3_SWD8_G1

---

## 🔄 Version History

### Version 1.0.0 (Current)
- Initial release
- Donor and Hospital authentication
- Blood request management
- Real-time notifications
- Donation tracking system
- OTP verification
- Custom SnackBar notifications
- Enhanced UI/UX

---

## 📝 Notes

- Ensure all environment variables are properly configured before running
- For production deployment, use release builds only
- Keep Firebase and Supabase credentials secure
- Regular database backups recommended
- Test on multiple devices before production release

---

**Made with ❤️ for saving lives through blood donation**
