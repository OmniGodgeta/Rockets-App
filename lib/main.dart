import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/root_shell.dart';
import 'app/theme.dart';
import 'data/iss_notification_service.dart';
import 'data/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final settingsRepository = SettingsRepository();
  await settingsRepository.init();

  // A "next ISS pass" notification goes stale once that pass happens, so
  // re-arm it for the next one on every app start (no-ops instantly if the
  // setting is off). Fire-and-forget: this does location + network calls and
  // must never block the UI from showing.
  if (settingsRepository.issPassAlertsEnabled) {
    unawaited(IssNotificationService().refreshSchedule());
  }

  runApp(RocketsApp(settingsRepository: settingsRepository));
}

class RocketsApp extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const RocketsApp({super.key, required this.settingsRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rockets',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      // Clamp the system font-size multiplier. Several screens (the bottom
      // nav in particular - "UNIVERSE" wrapping to two lines was reported on
      // a Pixel 8) use fixed-width slots sized for the default text scale;
      // an unclamped user accessibility setting above ~1.2x breaks those
      // layouts on real devices in a way flutter_test's default 1.0x scale
      // never catches.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler
            .clamp(minScaleFactor: 0.85, maxScaleFactor: 1.2);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          child: child!,
        );
      },
      home: RootShell(settingsRepository: settingsRepository),
    );
  }
}
