# Handoff — Rockets app

**Read this first if you're picking up work on this app.**

## 0.-3. Satellite Tracking, Favorites, Caching & UI Polish (2026-09-25)

After the foundation rebuild (v3.0.0), the following features have been implemented and verified:

### Accomplishments:
- **Satellite Search**: High-performance client-side search integrated into `SatellitesScreen`. Fetches live TLE data from CelesTrak with an in-memory cache in `SatelliteRepository` for rapid subsequent lookups.
- **Location Awareness**: Integrated `geolocator` to retrieve user coordinates, providing the required input for orbital propagation math.
- **Favorites System**: Created `FavoriteRepository` using Hive. Users can now favorite both satellites (by NORAD ID) and launches (by ID).
- **News Caching**: Implemented local caching for news articles in `NewsRepository` via Hive, enabling offline reading of recently fetched articles.
- **Launch Caching**: Implemented local caching for upcoming launches in `LaunchRepository` via Hive.
- **Satellite Details**: Enhanced `SatelliteDetailSheet` with real-time 'Next Pass' calculation using SGP4 and dynamic Favorites toggle.
- **Compass Mode**: Fully implemented azimuthal bearing calculation between user location and satellite ECI position using `flutter_compass`. Visualized via a compass overlay in `CompassScreen`.
- **UI Polish**: Unified loading and error states across all major tabs (`Rockets`, `Satellites`, `News`) using a centralized `LoadingOrErrorWrapper`. Adheres strictly to the SpaceX-inspired theme in `lib/app/theme.dart`.
- **Code Quality**: Resolved all linting issues; codebase passes `flutter analyze` with zero errors.
- **Build Verification**: Successfully generated a debug APK (`build/app/outputs/flutter-apk/app-debug.apk`).

### Status Table:

| Feature                | Status              | Notes                                                                 |
|-------------------------|---------------------|-----------------------------------------------------------------------|
| **Rockets**             | **Real, working.**  | Upcoming launches from LL2 API.                                       |
| **Satellites**          | **Search + Location + Compass.** | Native search + Geolocation + Azimuthal Bearing implemented.         |
| **Solar System**        | **Real, working.**  | Embedded NASA Eyes WebView.                                           |
| **News**                | **Cached, working.** | Fetches SFN v4 with local Hive persistence.                            |
| **Favorites**           | **Implemented.**    | Persistent storage via Hive for satellites and launches.              |
| **UI Polish**           | **Complete.**       | Consistent loading/error states across all tabs.                       |

### Next Steps for Future Agents:
1. **Release**: Tag version and produce a production APK if required by the operator.
