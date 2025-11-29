# Security Setup Guide 🔒

This guide explains how to configure the Blood Donation App with your own credentials while keeping them secure.

## ⚠️ Important: Before Pushing to GitHub

**NEVER commit these files with real credentials:**
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `.env` files

These files are already included in `.gitignore`.

## 📋 Setup Instructions

### 1. Supabase Configuration

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your **Project URL** and **Anon Key** from: Settings → API
3. Run the app with these environment variables:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key_here
```

### 2. Firebase Configuration

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android and iOS apps to your project
3. Download configuration files:
   - **Android**: `google-services.json` → place in `android/app/`
   - **iOS**: `GoogleService-Info.plist` → place in `ios/Runner/`
4. Run FlutterFire CLI:

```bash
flutterfire configure
```

This generates `lib/firebase_options.dart` with your credentials.

### 3. Template Files Available

We've provided template files for reference:
- `lib/firebase_options.dart.example` - Firebase options template
- `android/app/google-services.json.example` - Google Services template
- `.env.example` - Environment variables template

Copy these and fill in your actual values.

## 🛡️ For Team Members

If you're a team member who needs the actual credentials:

1. Ask the project lead for the `.env` file
2. Get the Firebase config files separately
3. **Never commit these to the repository**

## 🔄 Build Commands

### Development
```bash
# With environment variables
flutter run \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### Production Build
```bash
# Android APK
flutter build apk \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key

# iOS (on macOS)
flutter build ios \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

## ✅ Security Checklist

Before pushing to GitHub, verify:

- [ ] No API keys in `api_constants.dart` (should have empty defaults)
- [ ] `firebase_options.dart` is in `.gitignore`
- [ ] `google-services.json` is in `.gitignore`
- [ ] No `.env` files with real data
- [ ] No hardcoded passwords or secrets anywhere

## 🔍 Verify Your Setup

Run this command to check for accidentally committed secrets:
```bash
git diff --cached --name-only | xargs grep -l "eyJ\|AIza\|supabase.co"
```

If it returns any files, you have secrets that need to be removed!
