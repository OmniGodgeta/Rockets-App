# Rocket Launcher App - Changelog

## [v1.2.3] - 2026-10-02

### Fixed

- **ISS Live Now: the ISS was in the wrong place, and the "red lines
  everywhere".** Two stacked bugs in the orbit math. (1) The orbital
  library's time-since-epoch is in seconds, but its propagator wants
  minutes, so every position was computed 60x too far along the orbit. The
  93-minute path became ~60 orbits of scribble. (2) Its date conversion is
  a whole day off in some months, October included. Both fixed in
  `OrbitUtils`, so the marker, path, next-pass time and compass are all
  correct now. Checked against wheretheiss.at's live position: 0.00 deg
  error. `test/orbit_utils_test.dart` guards it.
- ISS Live Now no longer spins forever. CelesTrak sometimes hangs, so there's
  a 12 s timeout, a fallback source (wheretheiss.at) and the last orbit
  saved on the device. Waiting for a GPS fix no longer blocks the map.
- Weather Radar: clouds froze when zoomed in past level 7 (the radar
  provider's limit). Tiles are now upscaled from level 7.
- Aurora Forecast dark mode is actually readable.
- Rocket Scales: Starship V3 was 150 m. It's ~124.4 m (V2 123.1 m). The
  tallest bars no longer overflow their labels.

### Added

- **ISS: "Notify me when visible"** on the ISS screen. Alerts 5 min before a
  pass you can actually see: dark sky, ISS in sunlight, at least 10 deg up.
  It used to fire for any pass above the horizon, including daytime ones.
  The screen shows the next visible pass (when, how high, how long).
- Rocket Scales: real transparent side-view diagrams for 11 rockets and the
  human, drawn to scale, with credits (info button). Long March 5, Atlas V,
  H3, Delta IV Heavy and Starship V2 still use photos; no verified
  transparent diagram exists for them.
- ISS Live Now: stats panel restyled to match Scale of the Universe, plus a
  map legend explaining the line.

## [v1.2.2] - 2026-09-26

### Fixed

- **ISS Live Now: the real bug behind "the ISS keeps teleporting" and "too
  many lines."** The orbital-math library returns longitude wrapped into
  0-360 degrees, not the standard -180 to 180 that the map and this app's
  own trajectory code both assume - for half of every orbit (the whole
  western hemisphere), the position was being fed to the map completely
  wrong. Fixed at the source (`OrbitUtils.getSatellitePosition`), so it's
  correct everywhere that function is used, not just this screen.
- ISS Live Now: simplified the trajectory to current position onward
  through one orbit only (no past trace), per feedback that the combined
  past+future view was more line than needed.

## [v1.2.1] - 2026-09-25

Second round of fixes on top of v1.2.0, from real follow-up feedback.

### Fixed

- ISS Live Now trajectory: two differently-styled polylines (a dotted
  future segment) looked like clutter rather than one clean orbit line.
  Merged into a single continuous, solid track.
- Rocket Scales: the real photo now IS the accurately-scaled element
  (previously a small circular badge floating above a generic vector
  "spike"), anchored to a shared ground baseline across every rocket - the
  badge's old position, coupled to each rocket's own height, is why they
  looked misaligned.
- Scale of the Universe: fixed a real async race where swiping the slider
  quickly could let a stale, out-of-order network response overwrite the
  current item's photo with a different item's photo.
- Space Live / Rocket History: added a fallback "Open in YouTube" button for
  when in-app playback fails, since the reported error didn't match any
  documented YouTube IFrame API code and couldn't be reproduced without a
  device.
- Weather Radar: fixed a stale "OpenStreetMap" attribution label left over
  from the Esri satellite-imagery basemap swap.

### Added

- ISS Live Now: a visibility footprint circle (the ground region the ISS is
  currently above the horizon from - real satellite-footprint geometry, not
  a guessed radius), and the map now actually follows the ISS as it moves
  (it only ever centered once, at load, before this).
- ISS Live Now: zoom in/out/recenter buttons and a follow/unfollow toggle -
  there were no map controls at all before.
- Weather Radar: an animate/play button that auto-advances through radar
  frames, and a link out to Windy.com for wind/temperature layers (RainViewer's
  free API only covers precipitation).

## [v1.2.0] - 2026-09-25

Operator-reported polish pass across Weather Radar, Rocket Scales, Scale of
the Universe, Space Live, ISS Live Now, and the Gallery.

### Fixed

- Weather Radar: added a drag-to-scrub time bar across RainViewer's past and
  forecast frames (previously showed only the single latest frame).
- Rocket Scales: fixed the core bug where every rocket was scaled to fill its
  own box independently, so a 1.7 m human looked nearly as tall as a 70 m
  Falcon 9. All rockets now render on one shared scale, with real reference
  photos and a bottom slider from human up through Starship V3.
- Space Live: fixed YouTube error 153 (embedded playback blocked) by
  switching from a raw WebView embed to the youtube_player_iframe package.
- Gallery (renamed from "Astronomy Picture of the Day"): rebuilt as a
  native, dark-themed, infinite, newest-first feed pulling from both NASA
  APOD and the NASA Image and Video Library, instead of a single plain-white
  WebView page.
- Hamburger menu: the header box was oversized and pushed the first menu
  item down; tightened to a compact header.

### Added

- ISS Live Now: real ground-track trajectory (past + forecast path) drawn on
  the map, plus a realistic satellite-imagery basemap.
- Compass (Track with Compass): added the missing vertical/elevation axis -
  previously only showed horizontal heading. Now shows a real elevation
  angle (via SGP4 look-angle) against the device's own tilt, with a vertical
  gauge and tilt-up/tilt-down guidance.
- Scale of the Universe: expanded with asteroids, planet diameters, a white
  dwarf, a stellar black hole, the largest known stars, two supermassive
  black holes, and a dwarf galaxy; every entry now shows a real reference
  photo, and a new "COMPARE" mode lets you pick several objects and see them
  side by side, honestly to scale.
- Rocket History: a new drawer item with a brief written history of
  rocketry alongside a reference video.

## [v2.0.0] - 2026-09-23

### 🆕 Features

- ✅ Multi-provider rocket launch tracking (SpaceX, NASA, Rocket Lab, CNSA, ISRO, JAXA, ESA)
- ✅ Worldwide coverage for all major launch providers
- ✅ Live launch countdowns and status updates
- ✅ Video streaming integration (NASA TV, Planetary Radio)
- ✅ Offline mode with Hive cache storage
- ✅ Interactive world map view
- ✅ Provider directory with capabilities
- ✅ Favorites/bookmark launches
- ✅ Launch timeline visualization
- ✅ Material 3 theme (dark/light modes)

### 🛠️ Technical

- MVVM architecture with Repository pattern
- Bloc state management
- Hive offline storage
- YouTube API integration
- 32 Flutter files, ~6,000 lines of code

### 📱 Requirements

- Android 6.0+
- ~50MB storage
- Internet connection (optional for offline mode)

---

## [v1.0.0] - Initial Release

Basic rocket launch tracking app.
