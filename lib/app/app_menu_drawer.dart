import 'package:flutter/material.dart';

import 'theme.dart';
import '../../features/radar/radar_screen.dart';
import '../../features/about/about_screen.dart';
import '../../features/aurora/aurora_screen.dart';
import '../../features/rocket_scale/rocket_scale_screen.dart';
import '../../features/scale/scale_screen.dart';
import '../../features/satellites/iss_live_now_screen.dart';
import '../../features/apod/apod_screen.dart';
import '../../features/history/rocket_history_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/space_live/space_live_screen.dart';
import '../../data/settings_repository.dart';

/// The hamburger drawer only holds things that aren't already one of the six
/// bottom-nav tabs (Rockets/Sats/Sol/Galaxy/Universe/News) - it used to
/// duplicate all six of those as its own list tiles on top of the identical
/// bottom nav, which was confusing rather than useful.
class AppMenuDrawer extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const AppMenuDrawer({super.key, required this.settingsRepository});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppTheme.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 88,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              alignment: Alignment.bottomLeft,
              decoration: const BoxDecoration(
                color: AppTheme.surface,
              ),
              child: const Text(
                'Rockets',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined,
                  color: AppTheme.textPrimary),
              title: const Text(
                'Settings',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                          settingsRepository: settingsRepository)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.radar, color: AppTheme.textPrimary),
              title: const Text(
                'Weather Radar',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RadarScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_outlined,
                  color: AppTheme.textPrimary),
              title: const Text(
                'Aurora Forecast',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuroraScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.straighten, color: AppTheme.textPrimary),
              title: const Text(
                'Rocket Scales',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RocketScaleScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.zoom_out_map, color: AppTheme.textPrimary),
              title: const Text(
                'Scale of the Universe',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScaleScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.gps_fixed, color: AppTheme.textPrimary),
              title: const Text(
                'ISS Live Now',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const IssLiveNowScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: AppTheme.textPrimary),
              title: const Text(
                'Space Live',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SpaceLiveScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.image_outlined, color: AppTheme.textPrimary),
              title: const Text(
                'Gallery',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ApodScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.history_edu, color: AppTheme.textPrimary),
              title: const Text(
                'Rocket History',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RocketHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.info_outline, color: AppTheme.textPrimary),
              title: const Text(
                'About',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
