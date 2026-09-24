import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ABOUT')),
      body: Center(
        child: Text(
          'Rockets App\nVersion 1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      ),
    );
  }
}
