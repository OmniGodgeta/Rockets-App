import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

class RadarScreen extends StatefulWidget {
  final double? lat;
  final double? lon;

  const RadarScreen({super.key, this.lat, this.lon});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final String url = (widget.lat != null && widget.lon != null)
        ? 'https://zoom.earth/maps/radar/#view=${widget.lat},${widget.lon},8z'
        : 'https://zoom.earth/maps/radar/';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WEATHER RADAR')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
