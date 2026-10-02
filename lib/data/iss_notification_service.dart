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

  /// When the scheduled alert is for, so the ISS screen can show it.
  static DateTime? scheduledPassStart;

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
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15)),
      ).catchError((_) async =>
          await Geolocator.getLastKnownPosition() ??
          (throw Exception('no location')));

      final satelliteRepository = SatelliteRepository();
      final iss = await satelliteRepository.fetchIssSatellite();
      // A VISIBLE pass (dark sky, ISS sunlit, 10+ deg up), not merely
      // "above the horizon", which used to alert for daytime passes you
      // can't see. Visible passes come in multi-day windows with gaps of a
      // week or more, hence the 14-day search.
      final pass = OrbitUtils.calculateNextVisiblePass(
        iss,
        position.latitude,
        position.longitude,
        position.altitude / 1000,
        range: const Duration(days: 14),
      );
      if (pass == null) return;
      scheduledPassStart = pass.start;

      await _initialize();
      await _notifications.cancel(_notificationId);

      final alertTime = tz.TZDateTime.from(
          pass.start.subtract(const Duration(minutes: 5)), tz.local);
      final now = tz.TZDateTime.now(tz.local);
      if (alertTime.isBefore(now)) return;

      final minutes = (pass.duration.inSeconds / 60).ceil();
      await _notifications.zonedSchedule(
        _notificationId,
        'ISS visible in 5 minutes',
        'Look up: the ISS will cross your sky for about $minutes min, '
            'up to ${pass.maxElevationDeg.round()}° above the horizon.',
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
