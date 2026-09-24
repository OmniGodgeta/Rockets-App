import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/launch.dart';

class LaunchNotificationService {
  static final LaunchNotificationService _instance = LaunchNotificationService._internal();
  factory LaunchNotificationService() => _instance;
  LaunchNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    // Request notification permission for Android 13+
    await Permission.notification.request();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
    _initialized = true;
  }

  /// Schedules a notification for 15 minutes before the launch net time.
  Future<void> scheduleNotification(Launch launch) async {
    if (!_initialized) await initialize();

    final netUtc = launch.net.toUtc();
    final scheduledTime = tz.TZDateTime.from(netUtc.subtract(const Duration(minutes: 15)), tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledTime.isBefore(now)) return;

    // Use a stable integer ID based on the launch ID string
    final int notificationId = _hashStringToInt(launch.id);

    await _notifications.zonedSchedule(
      notificationId,
      'Launch Reminder!',
      'The ${launch.name} launch is happening in 15 minutes.',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'launch_reminders',
          'Launch Reminders',
          channelDescription: 'Notifications for favorited launches',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(String launchId) async {
    if (!_initialized) await initialize();
    final int notificationId = _hashStringToInt(launchId);
    await _notifications.cancel(notificationId);
  }

  int _hashStringToInt(String input) {
    // Simple DJB2 hash or similar to get a stable non-negative int
    var hash = 5381;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) + hash) + input.codeUnitAt(i);
    }
    return hash & 0x7FFFFFFF; // Ensure positive 32-bit signed integer
  }
}
