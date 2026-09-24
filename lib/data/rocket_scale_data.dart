class RocketScale {
  final String name;
  final double heightMeters;
  final double diameterMeters;

  const RocketScale({
    required this.name,
    required this.heightMeters,
    required this.diameterMeters,
  });
}

const List<RocketScale> rocketScaleData = [
  RocketScale(name: 'Falcon 9 Block 5', heightMeters: 70.0, diameterMeters: 3.7),
  RocketScale(name: 'Falcon Heavy', heightMeters: 70.0, diameterMeters: 3.7),
  RocketScale(name: 'Starship + Super Heavy', heightMeters: 124.0, diameterMeters: 9.0),
  RocketScale(name: 'Saturn V', heightMeters: 111.0, diameterMeters: 10.0),
  RocketScale(name: 'Space Shuttle (stack)', heightMeters: 56.0, diameterMeters: 8.7),
  RocketScale(name: 'SLS Block 1', heightMeters: 98.0, diameterMeters: 8.4),
  RocketScale(name: 'Delta IV Heavy', heightMeters: 72.0, diameterMeters: 5.0),
  RocketScale(name: 'Atlas V', heightMeters: 63.0, diameterMeters: 3.8),
  RocketScale(name: 'Ariane 5', heightMeters: 52.0, diameterMeters: 5.4),
  RocketScale(name: 'Ariane 6', heightMeters: 63.0, diameterMeters: 5.4),
  RocketScale(name: 'Soyuz-2 (core stack)', heightMeters: 46.0, diameterMeters: 2.95),
  RocketScale(name: 'Electron', heightMeters: 18.0, diameterMeters: 1.2),
  RocketScale(name: 'New Glenn', heightMeters: 98.0, diameterMeters: 7.0),
  RocketScale(name: 'Long March 5', heightMeters: 57.0, diameterMeters: 5.0),
  RocketScale(name: 'H3', heightMeters: 63.0, diameterMeters: 5.27),
];

const double averageHumanHeight = 1.7;
