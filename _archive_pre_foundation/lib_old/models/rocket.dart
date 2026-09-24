import 'launch.dart';

// Rocket data
class Rocket {
  final String id;
  final String name;
  final String type;
  final bool active;
  final String firstFlight;
  final String manufacturer;
  final String height;
  final String diameter;

  Rocket({
    required this.id,
    required this.name,
    required this.type,
    this.active = false,
    this.firstFlight = '',
    this.manufacturer = '',
    this.height = '',
    this.diameter = '',
  });
}

// Launch site
class LaunchSite {
  final String name;
  final double latitude;
  final double longitude;

  LaunchSite({
    required this.name,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
}
