import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

class ISSTrackerScreen extends StatefulWidget {
  const ISSTrackerScreen({super.key});

  @override
  State<ISSTrackerScreen> createState() => _ISSTrackerScreenState();
}

class _ISSTrackerScreenState extends State<ISSTrackerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Use a URL that provides a visual mapping of the ISS orbit or similar satellite-centric view.
    // For simplicity and consistency with other WebView screens, we deep link to a satellite map.
    const String url = 'https://satellitemap.space/?iss=true';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISS Tracker', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.background,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Container(
        color: AppTheme.background,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
