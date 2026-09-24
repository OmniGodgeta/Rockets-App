import 'package:flutter/material.dart';

import 'theme.dart';
import '../../features/radar/radar_screen.dart';
import '../../features/about/about_screen.dart';
import '../../features/aurora/aurora_screen.dart';
import '../../features/rockets/rockets_screen.dart';
import '../../features/rocket_scale/rocket_scale_screen.dart';
import '../../features/satellites/satellites_screen.dart';
import '../../features/satellites/iss_tracker_screen.dart';
import '../../features/solar_system/solar_system_screen.dart';
import '../../features/galaxy/galaxy_screen.dart';
import '../../features/universe/universe_screen.dart';
import '../../features/news/news_screen.dart';
import '../../features/apod/apod_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../data/settings_repository.dart';

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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.surface,
              ),
              child: Text(
                'Rockets',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
              title: const Text(
                'Settings',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(settingsRepository: settingsRepository)),
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
              leading: const Icon(Icons.nightlight_outlined, color: AppTheme.textPrimary),
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
              leading: const Icon(Icons.rocket_launch, color: AppTheme.textPrimary),
              title: const Text(
                'Rockets',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RocketsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.straighten, color: AppTheme.textPrimary),
              title: const Text(
                'Rocket Scales',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RocketScaleScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.satellite_alt, color: AppTheme.textPrimary),
              title: const Text(
                'Satellites',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SatellitesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.gps_fixed, color: AppTheme.textPrimary),
              title: const Text(
                'ISS Tracker',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ISSTrackerScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny, color: AppTheme.textPrimary),
              title: const Text(
                'Solar System',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SolarSystemScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.textPrimary),
              title: const Text(
                'Galaxy',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GalaxyScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.public, color: AppTheme.textPrimary),
              title: const Text(
                'Universe',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UniverseScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper, color: AppTheme.textPrimary),
              title: const Text(
                'News',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: AppTheme.textPrimary),
              title: const Text(
                'Picture of the Day',
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
              leading: const Icon(Icons.info_outline, color: AppTheme.textPrimary),
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
