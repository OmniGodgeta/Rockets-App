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
          // Inject dark mode CSS to override spaceweather.gov's light theme.
          const String css = '''
            html, body {
              background-color: #121212 !important;
              color: #e0e0e0 !important;
            }
            a {
              color: #bb86fc !important;
            }
            table, th, td {
              background-color: #1e1e1e !important;
              color: #e0e0e0 !important;
              border-color: #333 !important;
            }
            img {
              filter: brightness(.8) contrast(1.2);
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
