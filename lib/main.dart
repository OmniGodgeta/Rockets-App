import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/root_shell.dart';
import 'app/theme.dart';
import 'data/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  final settingsRepository = SettingsRepository();
  await settingsRepository.init();
  
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
      home: RootShell(settingsRepository: settingsRepository),
    );
  }
}
