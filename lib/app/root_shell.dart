import 'package:flutter/material.dart';

import 'theme.dart';
import '../../features/rockets/rockets_screen.dart';
import '../../features/satellites/satellites_screen.dart';
import '../../features/solar_system/solar_system_screen.dart';
import '../../features/galaxy/galaxy_screen.dart';
import '../../features/universe/universe_screen.dart';
import '../../features/news/news_screen.dart';
import 'app_menu_drawer.dart';

/// The app's sections, each a button at the bottom of the app: Rockets,
/// Satellites, Solar System, Galaxy, News, Universe.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RocketsScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      SatellitesScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      SolarSystemScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      GalaxyScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      UniverseScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      NewsScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppMenuDrawer(),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: AppTheme.background,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.rocket_launch_outlined), selectedIcon: Icon(Icons.rocket_launch), label: 'ROCKETS'),
          NavigationDestination(icon: Icon(Icons.satellite_alt_outlined), selectedIcon: Icon(Icons.satellite_alt), label: 'SATS'),
          NavigationDestination(icon: Icon(Icons.public_outlined), selectedIcon: Icon(Icons.public), label: 'SOL'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'GALAXY'),
          NavigationDestination(icon: Icon(Icons.scatter_plot_outlined), selectedIcon: Icon(Icons.scatter_plot), label: 'UNIVERSE'),
          NavigationDestination(icon: Icon(Icons.newspaper_outlined), selectedIcon: Icon(Icons.newspaper), label: 'NEWS'),
        ],
      ),
    );
  }
}
