import 'package:flutter/material.dart';
import '../../app/theme.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WHAT\'S NEW')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Version History',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          _buildVersionEntry(
            context,
            'v0.6.0',
            'Hamburger menu, Weather Radar (with launch-site deep link), About screen.',
          ),
          _buildVersionEntry(
            context,
            'v0.5.1',
            'New app icon.',
          ),
          _buildVersionEntry(
            context,
            'v0.5.0',
            'Fixed "Unknown rocket/location" bug, bottom nav relabel (SATS/SOL) and reorder, live launch countdown.',
          ),
          _buildVersionEntry(
            context,
            'v0.4.0',
            'Universe tab, Favorites screen (satellites & launches).',
          ),
          _buildVersionEntry(
            context,
            'v0.3.0',
            'Galaxy tab.',
          ),
          _buildVersionEntry(
            context,
            'v0.2.1',
            'Fixed Rockets tab crash and a black-screen bug on satellite search.',
          ),
          _buildVersionEntry(
            context,
            'v0.2.0',
            'First public release: satellite tracking (search, SGP4 orbital math, compass), favorites, offline caching, UI polish.',
          ),
        ],
      ),
    );
  }

  Widget _buildVersionEntry(BuildContext context, String version, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            version,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
          ),
          const Divider(color: AppTheme.surfaceBorder, height: 32),
        ],
      ),
    );
  }
}
