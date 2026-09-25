import 'package:flutter/material.dart';

import 'theme.dart';
import '../../features/rockets/rockets_screen.dart';
import '../../features/rockets/livestream_screen.dart';
import '../../features/satellites/satellites_screen.dart';
import '../../features/solar_system/solar_system_screen.dart';
import '../../features/galaxy/galaxy_screen.dart';
import '../../features/universe/universe_screen.dart';
import '../../features/news/news_screen.dart';
import 'app_menu_drawer.dart';
import '../../data/launch_repository.dart';
import '../../data/settings_repository.dart';
import '../../models/launch.dart';

class RootShell extends StatefulWidget {
  final SettingsRepository settingsRepository;

  const RootShell({super.key, required this.settingsRepository});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _NavItem {
  const _NavItem(
      {required this.icon, required this.selectedIcon, required this.label});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const List<_NavItem> _navItems = [
  _NavItem(
      icon: Icons.rocket_launch_outlined,
      selectedIcon: Icons.rocket_launch,
      label: 'ROCKETS'),
  _NavItem(
      icon: Icons.satellite_alt_outlined,
      selectedIcon: Icons.satellite_alt,
      label: 'SATS'),
  _NavItem(
      icon: Icons.public_outlined, selectedIcon: Icons.public, label: 'SOL'),
  _NavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'GALAXY'),
  _NavItem(
      icon: Icons.scatter_plot_outlined,
      selectedIcon: Icons.scatter_plot,
      label: 'UNIVERSE'),
  _NavItem(
      icon: Icons.newspaper_outlined,
      selectedIcon: Icons.newspaper,
      label: 'NEWS'),
];

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RocketsScreen(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      SatellitesScreen(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      SolarSystemScreen(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      GalaxyScreen(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      UniverseScreen(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      NewsScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForLiveLaunch());
  }

  /// If a favorited-worthy launch is live right now (within the same window
  /// RocketCountdown/the launch card use for "HAPPENING NOW"), offer to jump
  /// straight into its livestream on app open instead of making the user go
  /// find it themselves.
  Future<void> _checkForLiveLaunch() async {
    try {
      final repository = LaunchRepository();
      await repository.init();
      final launches = await repository.fetchUpcoming();
      Launch? liveLaunch;
      for (final l in launches) {
        if (l.isHappeningNow && l.webcastUrl != null) {
          liveLaunch = l;
          break;
        }
      }
      if (!mounted || liveLaunch == null) return;
      // Closures below don't retain Dart's null-promotion of `liveLaunch`,
      // so bind it to a definitely-non-null local first.
      final Launch confirmedLaunch = liveLaunch;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Live Launch Happening Now!',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: Text(confirmedLaunch.name,
              style: const TextStyle(color: AppTheme.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('DISMISS'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LivestreamScreen(
                        url: confirmedLaunch.webcastUrl!,
                        title: confirmedLaunch.name),
                  ),
                );
              },
              child: const Text('WATCH NOW'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('RootShell: could not check for a live launch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppMenuDrawer(settingsRepository: widget.settingsRepository),
      body: _screens[_index],
      bottomNavigationBar: _AdaptiveBottomNav(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}

/// A bottom nav bar that never wraps its labels onto a second line,
/// regardless of screen width or system font scale.
///
/// The stock Material `NavigationBar` was reported wrapping the "UNIVERSE"
/// label onto two lines on a Google Pixel 8 - reproduced: its
/// `NavigationDestination` label doesn't clip/scale, it just wraps like any
/// other unconstrained Text once 6 destinations share a narrow phone width.
/// Each label here is wrapped in `FittedBox(fit: BoxFit.scaleDown)` with
/// `maxLines: 1`, so instead of wrapping it shrinks to fit whatever width
/// this particular device/tab count actually gives it.
class _AdaptiveBottomNav extends StatelessWidget {
  const _AdaptiveBottomNav(
      {required this.selectedIndex, required this.onDestinationSelected});

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border:
            Border(top: BorderSide(color: AppTheme.surfaceBorder, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _navItems.length; i++)
                Expanded(
                  child: _NavTile(
                    item: _navItems[i],
                    selected: i == selectedIndex,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile(
      {required this.item, required this.selected, required this.onTap});

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.accent : AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.selectedIcon : item.icon,
                color: color, size: 24),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
