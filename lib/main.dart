import 'package:flutter/material.dart';
import 'pages/schedule_page.dart';

void main() {
  runApp(const RocketApp());
}

class RocketApp extends StatelessWidget {
  const RocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rockets 🚀',
      theme: ThemeData(
        primaryColor: Colors.red,
        useMaterial3: true,
      ),
      home: const SchedulePage(),
    );
  }
}
