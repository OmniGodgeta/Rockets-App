import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hand-off to other apps on the phone (MainActivity's
/// "rockets/external_apps" channel). Every package here must also be in
/// AndroidManifest.xml's <queries>.
class ExternalApps {
  static const _channel = MethodChannel('rockets/external_apps');

  /// "ISS Live Now" by VKL Apps: the paid package first, then the free one.
  static const issLiveNow = ['com.nicedayapps.iss', 'com.nicedayapps.iss_free'];

  /// Stellarium Mobile by Noctua Software (the original Stellarium authors).
  static const stellarium = [
    'com.noctuasoftware.stellarium',
    'com.noctuasoftware.stellarium_free',
  ];

  /// Opens the first installed app from [packages]. Returns false if none
  /// are installed (or not on Android).
  static Future<bool> open(List<String> packages) async {
    try {
      final launched = await _channel
          .invokeMethod<String>('launch', {'packages': packages});
      return launched != null;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// The Play Store page for [package]: the Store app if present, else web.
  static Future<void> openStore(String package) async {
    var opened = false;
    try {
      opened = await launchUrl(Uri.parse('market://details?id=$package'),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      // No Play Store app on this device.
    }
    if (!opened) {
      await launchUrl(
          Uri.parse('https://play.google.com/store/apps/details?id=$package'),
          mode: LaunchMode.externalApplication);
    }
  }
}
