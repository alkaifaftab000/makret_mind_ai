# 🚀 MarketMind AI - Setup & Contribution Guide

## ✅ Your Setup Status

- ✅ Flutter 3.41.6 installed
- ✅ Dart 3.11.4 ready
- ✅ Android SDK configured (v36.1.0)
- ✅ Android Emulator available
- ✅ All dependencies installed
- ✅ Code generation completed
- ⚠️ Xcode not installed (needed for iOS testing)
- ✅ Git branch `sharma-ui` created and ready

---

## 🎯 Quick Start - Run on Android Phone

### Step 1: Enable USB Debugging on Your Android Phone

1. Open **Settings** on your Android phone
2. Tap **About Phone** (usually at the bottom)
3. Tap **Build Number** **7 times** - you'll see a toast saying "Developer mode enabled"
4. Go back and find **Developer Options** (now visible)
5. Enable **USB Debugging** (toggle it ON)
6. Tap **Allow** when prompted to allow USB debugging

### Step 2: Connect Your Phone to Mac

1. Connect your Android phone to your Mac using a USB cable
2. When prompted on your phone, tap **Allow** to allow USB debugging from this computer
3. Check if connected:

```bash
cd "/Users/anuragsharma/Workspace/Projects/APP Development/Flutter/makret_mind_ai"
flutter devices
```

You should see your phone listed with a device ID.

### Step 3: Run the App

```bash
cd "/Users/anuragsharma/Workspace/Projects/APP Development/Flutter/makret_mind_ai"
flutter run
```

The app will build and install on your phone automatically! 🎉

---

## 📱 Alternative: Run on Android Emulator

If you don't have a physical Android phone:

```bash
# List available emulators
flutter emulators

# Start an emulator (replace "emulator_name" with your emulator name)
flutter emulators --launch <emulator_name>

# Then run the app
flutter run
```

---

## 🍎 iOS Testing (Requires Xcode)

If you want to test on iPhone, install Xcode first:

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Or install full Xcode from App Store
# Then setup CocoaPods:
sudo gem install cocoapods
cd ios
pod install
cd ..

# Trust developer certificate in Xcode
open ios/Runner.xcworkspace
```

Then run: `flutter run -v`

---

## 🌿 Your Working Branch

- **Branch Name**: `sharma-ui`
- **Base**: `main`
- **Status**: Active and ready for contributions

### Making Changes:

1. **Create a feature branch** from your working branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** and test on your phone

3. **Commit and push**:
   ```bash
   git add .
   git commit -m "feat: describe your changes"
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request** on GitHub to merge into `sharma-ui`

---

## 📋 Development Checklist

Before starting development, ensure:

- [ ] You're on `sharma-ui` branch: `git branch` should show `* sharma-ui`
- [ ] App runs on your phone without errors: `flutter run`
- [ ] No critical analysis issues: `flutter analyze`
- [ ] All dependencies updated: `flutter pub get`

---

## 🛠️ Common Commands

```bash
# Navigate to project
cd "/Users/anuragsharma/Workspace/Projects/APP Development/Flutter/makret_mind_ai"

# Check current branch
git branch

# View connected devices
flutter devices

# Run app in debug mode
flutter run

# Run with verbose output (helpful for debugging)
flutter run -v

# Generate code (if you modify models)
flutter pub run build_runner build --delete-conflicting-outputs

# Check code quality
flutter analyze

# Format code
dart format lib/

# Get dependencies
flutter pub get

# Check for outdated packages
flutter pub outdated

# Hot reload (press 'r' during flutter run)
# Hot restart (press 'R' during flutter run)
# Stop app (press 'q' during flutter run)
```

---

## 🐛 Troubleshooting

### Phone not detected?
```bash
# Revoke USB debugging authorization and try again
flutter devices
adb devices -l
```

### App crashes on startup?
```bash
# Clear app data and cache
flutter clean
flutter pub get
flutter run
```

### Build errors?
```bash
# Regenerate code
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub get
flutter run
```

### Gradle issues on Android?
```bash
cd android
./gradlew clean
cd ..
flutter run
```

---

## 📚 Project Structure

```
lib/
├── main.dart                    # App entry point
├── constants/                   # App configuration
│   ├── app_colors.dart
│   ├── app_strings.dart
│   ├── app_text_styles.dart
│   └── api_constants.dart
├── models/                      # Data models
│   ├── brand_model.dart
│   ├── product_model.dart
│   └── user_model.dart
├── services/                    # Business logic
│   ├── auth_service.dart
│   ├── brand_service.dart
│   ├── product_service.dart
│   └── api_service.dart
├── screens/                     # UI pages
│   ├── splash/
│   ├── onboarding/
│   ├── auth/
│   ├── home/
│   ├── product/
│   ├── templates/
│   ├── search/
│   ├── profile/
│   └── main_navigation_screen.dart
├── widgets/                     # Reusable components
├── utils/                       # Helper utilities
│   ├── image_utils.dart
│   ├── app_notification.dart
│   └── permission_utils.dart
└── theme/                       # Theme configuration
    └── app_theme.dart
```

---

## 🎯 Ready to Contribute!

You're all set! Start with:

1. ✅ Connect your phone or start emulator
2. ✅ Run: `flutter run`
3. ✅ Test the app
4. ✅ Create a feature branch: `git checkout -b feature/your-feature`
5. ✅ Make changes and commit
6. ✅ Push to `sharma-ui` branch

**Happy Coding! 🚀**

---

## ❓ Need Help?

- Flutter Docs: https://flutter.dev/docs
- Dart Docs: https://dart.dev/guides
- Flutter Forum: https://github.com/flutter/flutter/issues
- Your Backend: https://github.com/alkaifaftab000/adstudiobackend

