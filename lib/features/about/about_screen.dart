import 'package:flutter/material.dart';
import '../../app/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ABOUT')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Rockets',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Data & map sources',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(color: AppTheme.surfaceBorder),
          const SizedBox(height: 8),
          _buildSourceRow('Launch Library 2 (thespacedevs.com)', 'launches'),
          _buildSourceRow('CelesTrak', 'satellite TLE data'),
          _buildSourceRow('Spaceflight News API', 'news'),
          _buildSourceRow('NASA/JPL Solar System Scope', 'Solar System & Universe tabs'),
          _buildSourceRow('GalacticResource', 'Galaxy tab'),
          _buildSourceRow('Zoom Earth', 'weather radar'),
        ],
      ),
    );
  }

  Widget _buildSourceRow(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
