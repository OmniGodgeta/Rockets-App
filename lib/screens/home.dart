import 'package:flutter/material.dart';

class RocketLauncherApp extends StatefulWidget {
  const RocketLauncherApp({super.key});

  @override
  State<RocketLauncherApp> createState() => _RocketLauncherAppState();
}

class _RocketLauncherAppState extends State<RocketLauncherApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rocket Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00A1DE),
          secondary: const Color(0xFFC0392B),
          surface: const Color(0xFF1C1C1C),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// Home screen with navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// Schedule page
class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// World map page
class WorldMapPage extends StatelessWidget {
  const WorldMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// Providers page
class ProvidersPage extends StatelessWidget {
  const ProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// Favorites page
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// Settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

/// Live launches home screen content
class HomeScreenLive extends StatelessWidget {
  const HomeScreenLive({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
