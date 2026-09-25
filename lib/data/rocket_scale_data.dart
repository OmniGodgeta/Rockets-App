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

  const RocketScale({
    required this.name,
    required this.heightMeters,
    required this.diameterMeters,
    required this.wikipediaTitle,
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
  ),
  RocketScale(
    name: 'Electron',
    heightMeters: 18.0,
    diameterMeters: 1.2,
    wikipediaTitle: 'Electron_(rocket)',
  ),
  RocketScale(
    name: 'Soyuz-2 (core stack)',
    heightMeters: 46.0,
    diameterMeters: 2.95,
    wikipediaTitle: 'Soyuz-2',
  ),
  RocketScale(
    name: 'Ariane 5',
    heightMeters: 52.0,
    diameterMeters: 5.4,
    wikipediaTitle: 'Ariane_5',
  ),
  RocketScale(
    name: 'Space Shuttle (stack)',
    heightMeters: 56.0,
    diameterMeters: 8.7,
    wikipediaTitle: 'Space_Shuttle',
  ),
  RocketScale(
    name: 'Long March 5',
    heightMeters: 57.0,
    diameterMeters: 5.0,
    wikipediaTitle: 'Long_March_5',
  ),
  RocketScale(
    name: 'Atlas V',
    heightMeters: 63.0,
    diameterMeters: 3.8,
    wikipediaTitle: 'Atlas_V',
  ),
  RocketScale(
    name: 'Ariane 6',
    heightMeters: 63.0,
    diameterMeters: 5.4,
    wikipediaTitle: 'Ariane_6',
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
  ),
  RocketScale(
    name: 'Falcon Heavy',
    heightMeters: 70.0,
    diameterMeters: 3.7,
    wikipediaTitle: 'Falcon_Heavy',
  ),
  RocketScale(
    name: 'Delta IV Heavy',
    heightMeters: 72.0,
    diameterMeters: 5.0,
    wikipediaTitle: 'Delta_IV_Heavy',
  ),
  RocketScale(
    name: 'SLS Block 1',
    heightMeters: 98.0,
    diameterMeters: 8.4,
    wikipediaTitle: 'Space_Launch_System',
  ),
  RocketScale(
    name: 'New Glenn',
    heightMeters: 98.0,
    diameterMeters: 7.0,
    wikipediaTitle: 'New_Glenn',
  ),
  RocketScale(
    name: 'Saturn V',
    heightMeters: 111.0,
    diameterMeters: 10.0,
    wikipediaTitle: 'Saturn_V',
  ),
  RocketScale(
    name: 'Starship + Super Heavy (V2)',
    heightMeters: 124.0,
    diameterMeters: 9.0,
    wikipediaTitle: 'SpaceX_Starship',
  ),
  // Starship V3 (Block 3): SpaceX's current-generation stack, taller booster
  // and ship than V2. ~150 m total stack height, same 9 m diameter.
  RocketScale(
    name: 'Starship V3',
    heightMeters: 150.0,
    diameterMeters: 9.0,
    wikipediaTitle: 'SpaceX_Starship',
  ),
];
