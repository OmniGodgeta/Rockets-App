import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

/// "Solar System" tab: NASA's own interactive 3D solar system explorer,
/// embedded directly per the operator's own simplification ("it could simply
/// launch the NASA interactive 3D map of the solar system").
class SolarSystemScreen extends StatefulWidget {
  const SolarSystemScreen({super.key});

  @override
  State<SolarSystemScreen> createState() => _SolarSystemScreenState();
}

class _SolarSystemScreenState extends State<SolarSystemScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..loadRequest(Uri.parse('https://eyes.nasa.gov/apps/solar-system/#/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SOLAR SYSTEM')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
