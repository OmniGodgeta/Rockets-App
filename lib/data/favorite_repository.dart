import 'package:hive_flutter/hive_flutter.dart';
import '../models/launch.dart';
import 'launch_notification_service.dart';

class FavoriteRepository {
  static const String _satBoxName = 'favorites_satellites';
  static const String _launchBoxName = 'favorites_launches';

  late Box<String> _satelliteBox;
  late Box<String> _launchBox;
  final LaunchNotificationService _notificationService = LaunchNotificationService();

  Future<void> init() async {
    _satelliteBox = await Hive.openBox<String>(_satBoxName);
    _launchBox = await Hive.openBox<String>(_launchBoxName);
    await _notificationService.initialize();
  }

  // Satellite Favorites
  bool isSatelliteFavorite(String noradId) => _satelliteBox.containsKey(noradId);

  Future<void> toggleSatelliteFavorite(String noradId) async {
    if (isSatelliteFavorite(noradId)) {
      await _satelliteBox.delete(noradId);
    } else {
      await _satelliteBox.put(noradId, noradId);
    }
  }

  List<String> getFavoriteSatelliteIds() => _satelliteBox.keys.cast<String>().toList();

  // Launch Favorites
  bool isLaunchFavorite(String launchId) => _launchBox.containsKey(launchId);

  Future<void> toggleLaunchFavorite(String launchId, [Launch? launch]) async {
    if (isLaunchFavorite(launchId)) {
      await _launchBox.delete(launchId);
      if (launch != null) {
        await _notificationService.cancelNotification(launchId);
      }
    } else {
      await _launchBox.put(launchId, launchId);
      if (launch != null) {
        await _notificationService.scheduleNotification(launch);
      }
    }
  }

  List<String> getFavoriteLaunchIds() => _launchBox.keys.cast<String>().toList();
}
