import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

class AuroraScreen extends StatefulWidget {
  const AuroraScreen({super.key});

  @override
  State<AuroraScreen> createState() => _AuroraScreenState();
}

class _AuroraScreenState extends State<AuroraScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    const String url = 'https://www.spaceweather.gov/products/aurora-30-minute-forecast';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          // Dark mode for spaceweather.gov's light page: invert the whole
          // document, then invert media back so the aurora maps keep their
          // real colours. The earlier per-element override (body/table/a
          // colours) left the header and the "Current Space Weather
          // Conditions" box white and turned their text light grey on white,
          // which is less readable than no dark mode at all. Checked both by
          // rendering the live page in headless Chromium (2026-10-02).
          const String css = '''
            html {
              filter: invert(1) hue-rotate(180deg) !important;
              background: #fff !important;
            }
            img, video, canvas, iframe, [style*="background-image"] {
              filter: invert(1) hue-rotate(180deg) !important;
            }
          ''';
          _controller.runJavaScript('''
            var style = document.createElement('style');
            style.innerHTML = `$css`;
            document.head.appendChild(style);
          ''');
        },
      ))
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AURORA FORECAST')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
