import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'screens/schedule.dart';
import 'screens/map.dart';
import 'screens/providers.dart';
import 'screens/favorites.dart';
import 'screens/settings.dart';

void main() {
  runApp(const RocketApp());
}

class RocketApp extends StatelessWidget {
  const RocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rockets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00A1DE),
          secondary: const Color(0xFFC0392B),
          surface: const Color(0xFF1C1C1C),
        ),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

/// Navigation destination for different pages
abstract class Screen {
  const Screen({super.key});
  
  static const home = Home();
  static const schedule = Schedule();
  static const map = Map();
  static const providers = Providers();
  static const favorites = Favorites();
  static const settings = Settings();
}
