import 'package:hive_flutter/hive_flutter.dart';

class FavoriteRepository {
  static const String _satBoxName = 'favorites_satellites';
  static const String _launchBoxName = 'favorites_launches';

  late Box<String> _satelliteBox;
  late Box<String> _launchBox;

  Future<void> init() async {
    _satelliteBox = await Hive.openBox<String>(_satBoxName);
    _launchBox = await Hive.openBox<String>(_launchBoxName);
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

  Future<void> toggleLaunchFavorite(String launchId) async {
    if (isLaunchFavorite(launchId)) {
      await _launchBox.delete(launchId);
    } else {
      await _launchBox.put(launchId, launchId);
    }
  }

  List<String> getFavoriteLaunchIds() => _launchBox.keys.cast<String>().toList();
}
