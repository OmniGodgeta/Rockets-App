import 'package:hive_flutter/hive_flutter.dart';

class SettingsRepository {
  static const String _settingsBoxName = 'app_settings';

  late Box<bool> _settingsBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox<bool>(_settingsBoxName);
  }

  bool get useMetric {
    return _settingsBox.get('useMetric', defaultValue: true) ?? true;
  }

  Future<void> setUseMetric(bool value) async {
    await _settingsBox.put('useMetric', value);
  }
}
