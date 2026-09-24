import 'package:flutter/material.dart';

import '../../app/theme.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WEATHER RADAR')),
      body: Center(
        child: Text(
          'Radar functionality coming soon.',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}
