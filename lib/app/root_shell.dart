import 'package:flutter/material.dart';

import '../features/galaxy/galaxy_screen.dart';
import '../features/news/news_screen.dart';
import '../features/rockets/rockets_screen.dart';
import '../features/satellites/satellites_screen.dart';
import '../features/solar_system/solar_system_screen.dart';
import '../features/universe/universe_screen.dart';
import 'theme.dart';

/// The app's sections, each a button at the bottom of the app: Rockets,
/// Satellites, Solar System, Galaxy, News, Universe.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    RocketsScreen(),
    SatellitesScreen(),
    SolarSystemScreen(),
    GalaxyScreen(),
    NewsScreen(),
    UniverseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Build only the active tab: the Satellites/Solar System tabs load a
      // full webview, and eagerly building all 4 at once (IndexedStack)
      // wastes network/JS engine resources for tabs the user hasn't opened.
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: AppTheme.background,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.rocket_launch_outlined), selectedIcon: Icon(Icons.rocket_launch), label: 'ROCKETS'),
          NavigationDestination(icon: Icon(Icons.satellite_alt_outlined), selectedIcon: Icon(Icons.satellite_alt), label: 'SATELLITES'),
          NavigationDestination(icon: Icon(Icons.public_outlined), selectedIcon: Icon(Icons.public), label: 'SOLAR SYSTEM'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'GALAXY'),
          NavigationDestination(icon: Icon(Icons.newspaper_outlined), selectedIcon: Icon(Icons.newspaper), label: 'NEWS'),
          NavigationDestination(icon: Icon(Icons.scatter_plot_outlined), selectedIcon: Icon(Icons.scatter_plot), label: 'UNIVERSE'),
        ],
      ),
    );
  }
}
