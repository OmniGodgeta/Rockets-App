import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../utils/orbit_utils.dart';
import 'satellite_repository.dart';
import 'settings_repository.dart';

/// Schedules a local notification a few minutes before the ISS next becomes
/// visible from the user's current location. Unlike launch reminders (fixed
/// offset from a known time), a "next pass" has to be computed from live
/// orbital propagation, so this is rearmed explicitly (toggling the setting
/// on, or on each app start while it's on) rather than scheduled once and
/// forgotten.
class IssNotificationService {
  static const int _notificationId = 0x15544; // arbitrary, stable, ISS-themed
  static final IssNotificationService _instance =
      IssNotificationService._internal();
  factory IssNotificationService() => _instance;
  IssNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    await Permission.notification.request();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications
        .initialize(const InitializationSettings(android: androidSettings));
    _initialized = true;
  }

  /// Recomputes the next ISS pass over the user's current location and
  /// (re)schedules the flyover notification for a few minutes before it,
  /// replacing any previously scheduled one. Does nothing if the setting is
  /// off or location/permission isn't available - failures here are
  /// non-fatal background best-effort, not something to surface as an error.
  Future<void> refreshSchedule() async {
    try {
      final settings = SettingsRepository();
      await settings.init();
      if (!settings.issPassAlertsEnabled) {
        await cancel();
        return;
      }

      var status = await Permission.location.status;
      if (status.isDenied) status = await Permission.location.request();
      if (!status.isGranted) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      final satelliteRepository = SatelliteRepository();
      final iss = await satelliteRepository.fetchIssSatellite();
      final nextPass = OrbitUtils.calculateNextPass(
        iss,
        position.latitude,
        position.longitude,
        position.altitude / 1000,
      );
      if (nextPass == null) return;

      await _initialize();

      final alertTime = tz.TZDateTime.from(
          nextPass.subtract(const Duration(minutes: 5)), tz.local);
      final now = tz.TZDateTime.now(tz.local);
      if (alertTime.isBefore(now)) return;

      await _notifications.zonedSchedule(
        _notificationId,
        'ISS Flyover Soon!',
        'The International Space Station will be visible overhead in about 5 minutes.',
        alertTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'iss_pass_alerts',
            'ISS Flyover Alerts',
            channelDescription:
                'Notifies you shortly before the ISS is visible overhead',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint(
          'IssNotificationService: could not schedule flyover alert: $e');
    }
  }

  Future<void> cancel() async {
    if (!_initialized) await _initialize();
    await _notifications.cancel(_notificationId);
  }
}
