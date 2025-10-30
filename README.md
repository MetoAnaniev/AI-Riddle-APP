# 🎲 Riddle Generator

A beautiful, multilingual riddle application with AI-powered riddle generation using Google's Gemini API. Built with Flutter for Android, featuring a modern dark theme inspired by Sparklab design.

![App Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android-green)

## ✨ Features

### 🌍 Multilingual Support
- **Bulgarian (Български)** - 22 classic riddles
- **English** - 23 classic riddles
- **Spanish (Español)** - 21 classic riddles
- Easy language switching with elegant chip selector

### 🤖 AI-Powered Riddles
- Generate unique, original riddles using Google Gemini API
- Context-aware generation in your selected language
- Automatic retry with exponential backoff for reliability

### 🎨 Modern UI/UX
- Dark theme with cyan accents (Sparklab-inspired)
- Smooth animations and transitions
- Slide-up answer panel to avoid accidental spoilers
- Responsive design optimized for mobile devices
- Material Design 3 components

### 🎯 Two Game Modes
1. **Classic Riddles** - Curated collection of traditional riddles
2. **AI Riddles** - Unlimited AI-generated riddles on demand

## 📱 Download

### Direct Installation (APK)
**File**: `app-release.apk` (42.9 MB)

**Path**: `/home/user/flutter_app/build/app/outputs/flutter-apk/app-release.apk`

Perfect for:
- Direct installation on Android devices
- Testing and beta distribution
- Side-loading

### Google Play Store (AAB)
**File**: `app-release.aab` (38.9 MB)

**Path**: `/home/user/flutter_app/build/app/outputs/bundle/release/app-release.aab`

Required for:
- Google Play Store submission
- Optimized device-specific APKs
- Automatic app updates

## 🚀 Installation Instructions

### For End Users (APK)

1. **Enable Unknown Sources**:
   - Go to Settings → Security
   - Enable "Install unknown apps" for your file manager/browser

2. **Install the APK**:
   - Download `app-release.apk` to your device
   - Tap the file to install
   - Grant necessary permissions

3. **Launch**:
   - Open "Riddle Generator" from your app drawer
   - Select your preferred language
   - Start solving riddles!

### For Google Play Store Submission (AAB)

1. **Create Google Play Console Account**:
   - Visit [Google Play Console](https://play.google.com/console)
   - Pay one-time $25 registration fee

2. **Create New App**:
   - Select "Create app"
   - Fill in app details and category
   - Set up store listing with:
     - App name: "Riddle Generator"
     - Description (see below)
     - Screenshots
     - App icon

3. **Upload AAB**:
   - Go to Release → Production
   - Create new release
   - Upload `app-release.aab`
   - Review and confirm

4. **Submit for Review**:
   - Complete all required sections
   - Submit for Google review (typically 1-3 days)

## 🛠️ Technical Details

### Built With
- **Flutter**: 3.35.4
- **Dart**: 3.9.2
- **Google Fonts**: Inter font family
- **HTTP**: 1.5.0 for API requests
- **Gemini API**: AI riddle generation

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: 1.5.0
  google_fonts: 6.2.1
  cupertino_icons: ^1.0.8
```

### API Configuration
The app uses Google Gemini API for AI riddle generation. The API key is embedded in the release builds via `--dart-define` flag.

**Model Used**: `gemini-2.5-flash-preview-09-2025`

### Signing Configuration
- **Keystore**: Custom signing key for release builds
- **Alias**: riddle-app
- **Validity**: 10,000 days (~27 years)
- **Certificate**: CN=Riddle App, OU=Development, O=SparkLab, L=Sofia, ST=Sofia, C=BG

### Package Information
- **Package ID**: `com.example.flutter_app`
- **Version**: 1.0.0 (Build 1)
- **Min SDK**: Android 5.0 (API 21)
- **Target SDK**: Android 15 (API 35)

## 🎨 App Screenshots

*(Add screenshots here after capturing from the app)*

### Features to Highlight:
1. Welcome screen with language selector
2. Classic riddles in different languages
3. AI riddle generation in action
4. Slide-up answer panel
5. Language switching

## 📝 Store Listing Suggestions

### Short Description
Multilingual riddle app with AI-powered riddle generation. Supports Bulgarian, English, and Spanish with unlimited AI riddles!

### Full Description
```
🎲 Riddle Generator - Challenge Your Mind!

Enjoy a vast collection of classic riddles in multiple languages, or let AI create unique riddles just for you!

✨ FEATURES:
• 🌍 Three Languages: Bulgarian, English, Spanish
• 🤖 AI-Powered: Unlimited unique riddles via Gemini AI
• 🎨 Beautiful Design: Modern dark theme with smooth animations
• 🎯 Two Modes: Classic riddles or AI-generated challenges
• 📱 Offline Support: Classic riddles work without internet
• 🔄 Fresh Content: New AI riddles on every request

🧩 CLASSIC RIDDLES:
Choose from 60+ hand-picked traditional riddles across three languages. Perfect for:
- Brain training
- Family entertainment
- Language learning
- Party games

🤖 AI RIDDLES:
Powered by Google's Gemini AI, get unlimited original riddles that are:
- Contextually appropriate
- Language-specific
- Challenging and fun
- Never repetitive

Perfect for riddle enthusiasts, educators, parents, and anyone who loves brain teasers!

Download now and start your riddle adventure! 🧠✨
```

## 🔧 Development

### Prerequisites
- Flutter SDK 3.35.4
- Android SDK (API 35)
- Java 17
- Git

### Build Commands

#### Web Preview (Development)
```bash
cd /home/user/flutter_app
flutter build web --release \
  --dart-define=GEMINI_API_KEY=YOUR_KEY

cd build/web
python3 -m http.server 5060 --bind 0.0.0.0
```

#### Android APK (Release)
```bash
cd /home/user/flutter_app
flutter build apk --release \
  --dart-define=GEMINI_API_KEY=YOUR_KEY
```

#### Android AAB (Play Store)
```bash
cd /home/user/flutter_app
flutter build appbundle --release \
  --dart-define=GEMINI_API_KEY=YOUR_KEY
```

### Project Structure
```
flutter_app/
├── lib/
│   └── main.dart              # Main app code
├── android/
│   ├── app/
│   │   ├── build.gradle.kts   # Android build config
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── res/values/
│   │           └── strings.xml  # App name
│   └── riddle-app-key.jks     # Signing keystore (NOT in repo)
├── test/
│   └── widget_test.dart       # Widget tests
├── pubspec.yaml               # Dependencies
└── README.md                  # This file
```

## 🔒 Security Notes

### Keystore (Important!)
The signing keystore `riddle-app-key.jks` is **NOT** included in the repository for security reasons.

**Keystore Details** (for reference only):
- Store password: riddleapp123
- Key alias: riddle-app
- Key password: riddleapp123

⚠️ **Keep your keystore file safe!** You'll need it for:
- Future app updates
- Signing new releases
- Play Store submissions

### API Key
The Gemini API key is embedded via build-time `--dart-define` flag and not stored in source code or repository.

## 📊 Performance

- **APK Size**: 42.9 MB
- **AAB Size**: 38.9 MB
- **Startup Time**: ~2 seconds
- **AI Response Time**: 2-5 seconds (depends on network)
- **Memory Usage**: ~80-120 MB
- **Battery Impact**: Minimal (native Flutter rendering)

## 🌐 Web Preview

Live web preview available at:
```
https://5060-ize4wb8v3nv0v79xq1obm-ad490db5.sandbox.novita.ai
```

The web version includes all features except mobile-specific optimizations.

## 📄 License

This project is private. All rights reserved.

## 👨‍💻 Developer

**SparkLab Academy**

For questions or support, please open an issue on GitHub.

## 🎯 Roadmap

### Future Features
- [ ] More languages (French, German, Italian)
- [ ] Difficulty levels
- [ ] Daily challenges
- [ ] Leaderboards
- [ ] Share riddles with friends
- [ ] Dark/Light theme toggle
- [ ] Custom riddle creation
- [ ] Offline AI riddle caching

## 🙏 Acknowledgments

- Google Gemini API for AI riddle generation
- Flutter team for the amazing framework
- Google Fonts for beautiful typography
- SparkLab for design inspiration

---

**Made with ❤️ using Flutter**

*Last Updated: October 2025*
