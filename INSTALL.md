# Setting Up the Rockets App

## Quick Start

### 1. Clone the Repository (if on GitHub)
```bash
git clone https://github.com/your-username/Rockets-App.git
cd Rockets-App
```

### 2. Get Flutter Dependencies
```bash
flutter pub get
```

### 3. Run on Your Device
```bash
flutter run
```

### 4. Build for Release
```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Installation on Android

1. Transfer the APK to your Android phone
2. Enable "Install from Unknown Sources" in Settings
3. Open the APK file to install

## Features Included

✅ **Live Launch Schedule** - Shows upcoming SpaceX launches
✅ **YouTube Integration** - Direct links to watch broadcasts  
✅ **Launch Details** - Rocket info, mission objectives
✅ **Pulls from SpaceX API** - Official launch data
✅ **Simple, Clean Interface** - Space Launch Now inspired design

## Data Sources

- **SpaceX Launch API** (api.spacexdata.com) - Official launch schedules
- **YouTube** - Launch broadcast videos
- **X (Twitter)** - SpaceX social media integration

## File Structure

```
lib/
├── main.dart                 # App entry point
├── pages/
│   └── launch_schedule_page.dart    # Main schedule screen
├── widgets/
│   └── launch_card_widget.dart      # Launch cards
├── services/
│   └── launch_data_service.dart   # API data fetching
└── screens/
    └── launch_video_player.dart        # Video integration

android/                       # Android config
pubspec.yaml                   # Dependencies
README.md                      # Documentation
```

## API Usage

The app uses the public SpaceX API at `https://api.spacexdata.com/v4/launches/upcoming`

No authentication needed - it's a free, open API!
