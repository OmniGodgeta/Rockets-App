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
