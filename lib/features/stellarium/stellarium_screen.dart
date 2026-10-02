import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';
import '../../utils/external_apps.dart';

/// Star map. Opens the Stellarium Mobile app when it's installed; otherwise
/// shows Stellarium Web (the official free browser version, same sky
/// engine) right here, with a button to get the app.
class StellariumScreen extends StatefulWidget {
  const StellariumScreen({super.key});

  /// The menu calls this: hands off to the real app if present, else pushes
  /// the in-app web version.
  /// Takes the NavigatorState, not a BuildContext: the menu closes the
  /// drawer first, and the drawer's context is gone by the time the
  /// installed-app check returns.
  static Future<void> open(NavigatorState navigator) async {
    if (await ExternalApps.open(ExternalApps.stellarium)) return;
    await navigator.push(
        MaterialPageRoute(builder: (_) => const StellariumScreen()));
  }

  @override
  State<StellariumScreen> createState() => _StellariumScreenState();
}

class _StellariumScreenState extends State<StellariumScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse('https://stellarium-web.org/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STAR MAP'),
        actions: [
          TextButton.icon(
            onPressed: () => ExternalApps.openStore(ExternalApps.stellarium.last),
            icon: const Icon(Icons.download, color: AppTheme.accent, size: 18),
            label: const Text('GET APP',
                style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
                child: CircularProgressIndicator(color: AppTheme.accent)),
        ],
      ),
    );
  }
}
