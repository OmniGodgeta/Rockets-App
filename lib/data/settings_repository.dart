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

  /// Whether a favorited launch should get a reminder notification 15
  /// minutes before it happens.
  bool get launchAlertsEnabled {
    return _settingsBox.get('launchAlertsEnabled', defaultValue: true) ?? true;
  }

  Future<void> setLaunchAlertsEnabled(bool value) async {
    await _settingsBox.put('launchAlertsEnabled', value);
  }

  /// Whether to notify the user shortly before the ISS becomes visible
  /// (above the horizon) from their current location.
  bool get issPassAlertsEnabled {
    return _settingsBox.get('issPassAlertsEnabled', defaultValue: false) ??
        false;
  }

  Future<void> setIssPassAlertsEnabled(bool value) async {
    await _settingsBox.put('issPassAlertsEnabled', value);
  }
}
