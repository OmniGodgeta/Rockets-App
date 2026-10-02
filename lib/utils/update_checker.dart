import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/theme.dart';

/// Releases are sideloaded APKs from GitHub, with no store to push updates,
/// so v1.2.3's ISS fix never reached the phone. On start this asks GitHub for
/// the latest release and offers its APK if it's newer than this build.
/// "Later" remembers that version so it doesn't nag on every launch.
class UpdateChecker {
  static const _latestUrl =
      'https://api.github.com/repos/OmniGodgeta/Rockets-App/releases/latest';

  static Future<void> check(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final response = await http
          .get(Uri.parse(_latestUrl),
              headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return;
      final release = jsonDecode(response.body) as Map<String, dynamic>;
      final latest = (release['tag_name'] as String? ?? '').replaceFirst('v', '');
      if (!_isNewer(latest, info.version)) return;

      final prefs = await Hive.openBox<String>('update_prefs');
      if (prefs.get('dismissed') == latest) return;

      final assets = (release['assets'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final apk = assets
          .map((a) => a['browser_download_url'] as String?)
          .firstWhere((u) => u != null && u.endsWith('.apk'),
              orElse: () => release['html_url'] as String?);
      if (apk == null || !context.mounted) return;

      final notes = _summary(release['body'] as String? ?? '');

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text('Rockets v$latest is available',
              style: const TextStyle(color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            child: Text(
              'You have v${info.version}.${notes.isEmpty ? '' : '\n\n$notes'}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.35),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                prefs.put('dismissed', latest);
                Navigator.pop(context);
              },
              child: const Text('LATER'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                // The browser downloads it; tapping the download installs it
                // over this version (same signing key).
                launchUrl(Uri.parse(apk), mode: LaunchMode.externalApplication);
              },
              child: const Text('DOWNLOAD UPDATE'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('UpdateChecker: $e');
    }
  }

  /// First sentence of each of the first few changelog bullets. Bullets wrap
  /// over several lines in the markdown, so join each one back up first.
  static String _summary(String body) {
    final bullets = RegExp(r'^- (.+?)(?=\n- |\n\n|\n#|(?![\s\S]))',
            multiLine: true, dotAll: true)
        .allMatches(body)
        .map((m) => m.group(1)!.replaceAll(RegExp(r'\s+'), ' ').replaceAll('**', ''));
    return bullets.take(4).map((b) {
      final end = b.indexOf('. ');
      final first = end > 0 ? b.substring(0, end + 1) : b;
      return '• ${first.length > 110 ? '${first.substring(0, 107)}…' : first}';
    }).join('\n');
  }

  /// Semver-ish: compares dotted numbers, so 1.2.10 > 1.2.9.
  static bool _isNewer(String latest, String current) {
    final a = latest.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final b = current.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final x = i < a.length ? a[i] : 0, y = i < b.length ? b[i] : 0;
      if (x != y) return x > y;
    }
    return false;
  }
}
