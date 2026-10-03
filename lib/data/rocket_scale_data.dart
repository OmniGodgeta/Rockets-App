/// A single reference point in the Rocket Size Comparison screen, sorted
/// ascending by [heightMeters] so the smallest (human) is first and the
/// largest (Starship V3) is last - matching the "scale of the universe"
/// slider pattern used elsewhere in the app.
///
/// [wikipediaTitle] is the exact English Wikipedia article title (verified
/// to resolve, 2026-09-25) used to fetch a real reference photo at runtime
/// via https://en.wikipedia.org/api/rest_v1/page/summary/<title> - a live
/// API call, not a hardcoded image URL, so it can't go stale the way a
/// hotlinked file path would.
class RocketScale {
  final String name;
  final double heightMeters;
  final double diameterMeters;
  final String wikipediaTitle;

  /// A bundled side-view diagram with a transparent background
  /// (`assets/rockets/`, sources and licences in its CREDITS.md). It fills the
  /// height-accurate box top to bottom, unlike a rectangular photo. Null means
  /// no verified transparent diagram was found, so the Wikipedia photo is used.
  final String? assetImage;

  const RocketScale({
    required this.name,
    required this.heightMeters,
    required this.diameterMeters,
    required this.wikipediaTitle,
    this.assetImage,
  });
}

const double averageHumanHeight = 1.7;

/// Sorted ascending by height - smallest (human) to largest (Starship V3).
/// The human reference is a real entry in this list (not special-cased in
/// the UI) so the shared to-scale rendering and the slider both treat it
/// like any other item.
const List<RocketScale> rocketScaleData = [
  RocketScale(
    name: 'Human being',
    heightMeters: averageHumanHeight,
    diameterMeters: 0.5,
    wikipediaTitle: 'Human_height',
    assetImage: 'assets/rockets/human.png',
  ),
  RocketScale(
    name: 'Electron',
    heightMeters: 18.0,
    diameterMeters: 1.2,
    wikipediaTitle: 'Electron_(rocket)',
    assetImage: 'assets/rockets/electron.png',
  ),
  RocketScale(
    name: 'Soyuz-2 (core stack)',
    heightMeters: 46.0,
    diameterMeters: 2.95,
    wikipediaTitle: 'Soyuz-2',
    assetImage: 'assets/rockets/soyuz2.png',
  ),
  RocketScale(
    name: 'Ariane 5',
    heightMeters: 52.0,
    diameterMeters: 5.4,
    wikipediaTitle: 'Ariane_5',
    assetImage: 'assets/rockets/ariane5.png',
  ),
  RocketScale(
    name: 'Space Shuttle (stack)',
    heightMeters: 56.0,
    diameterMeters: 8.7,
    wikipediaTitle: 'Space_Shuttle',
    assetImage: 'assets/rockets/space_shuttle.png',
  ),
  RocketScale(
    name: 'Long March 5',
    heightMeters: 57.0,
    diameterMeters: 5.0,
    wikipediaTitle: 'Long_March_5',
    assetImage: 'assets/rockets/long_march_5.png',
  ),
  RocketScale(
    name: 'Atlas V',
    heightMeters: 63.0,
    diameterMeters: 3.8,
    wikipediaTitle: 'Atlas_V',
    assetImage: 'assets/rockets/atlas_v.png',
  ),
  RocketScale(
    name: 'Ariane 6',
    heightMeters: 63.0,
    diameterMeters: 5.4,
    wikipediaTitle: 'Ariane_6',
    assetImage: 'assets/rockets/ariane6.png',
  ),
  RocketScale(
    name: 'H3',
    heightMeters: 63.0,
    diameterMeters: 5.27,
    wikipediaTitle: 'H3_(rocket)',
  ),
  RocketScale(
    name: 'Falcon 9 Block 5',
    heightMeters: 70.0,
    diameterMeters: 3.7,
    wikipediaTitle: 'Falcon_9',
    assetImage: 'assets/rockets/falcon9.png',
  ),
  RocketScale(
    name: 'Falcon Heavy',
    heightMeters: 70.0,
    diameterMeters: 3.7,
    wikipediaTitle: 'Falcon_Heavy',
    assetImage: 'assets/rockets/falcon_heavy.png',
  ),
  RocketScale(
    name: 'Delta IV Heavy',
    heightMeters: 72.0,
    diameterMeters: 5.0,
    wikipediaTitle: 'Delta_IV_Heavy',
    assetImage: 'assets/rockets/delta_iv_heavy.png',
  ),
  RocketScale(
    name: 'SLS Block 1',
    heightMeters: 98.0,
    diameterMeters: 8.4,
    wikipediaTitle: 'Space_Launch_System',
    assetImage: 'assets/rockets/sls.png',
  ),
  RocketScale(
    name: 'New Glenn',
    heightMeters: 98.0,
    diameterMeters: 7.0,
    wikipediaTitle: 'New_Glenn',
    assetImage: 'assets/rockets/new_glenn.png',
  ),
  RocketScale(
    name: 'Saturn V',
    heightMeters: 111.0,
    diameterMeters: 10.0,
    wikipediaTitle: 'Saturn_V',
    assetImage: 'assets/rockets/saturn_v.png',
  ),
  RocketScale(
    name: 'Starship + Super Heavy (V2)',
    // Block 2: 71 m booster + 52.1 m ship (Wikipedia, checked 2026-10-02).
    heightMeters: 123.1,
    diameterMeters: 9.0,
    wikipediaTitle: 'SpaceX_Starship',
  ),
  // Starship V3 (Block 3): SpaceX's current-generation stack. Booster is
  // 72.3 m (Wikipedia, checked 2026-10-02) plus a ~52 m ship = ~124.4 m.
  // This used to say ~150 m, which is no Starship version that has flown and
  // made it look ~35% taller than it is next to Saturn V.
  RocketScale(
    name: 'Starship V3',
    heightMeters: 124.4,
    diameterMeters: 9.0,
    wikipediaTitle: 'SpaceX_Starship',
    assetImage: 'assets/rockets/starship_v3.png',
  ),
];
