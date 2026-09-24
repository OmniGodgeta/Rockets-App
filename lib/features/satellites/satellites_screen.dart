import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../app/theme.dart';

/// \"Satellites\" tab: a live Starlink-map-style 3D view of every satellite in
/// orbit (https://satellitemap.space).
class SatellitesScreen extends StatefulWidget {
  const SatellitesScreen({super.key});

  @override
  State<SatellitesScreen> createState() => _SatellitesScreenState();
}

class _SatellitesScreenState extends State<SatellitesScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..loadRequest(Uri.parse('https://satellitemap.space/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SATELLITES'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search satellite name (coming soon)',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppTheme.surfaceBorder),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.surface,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compass direction-finder mode: coming soon')),
          );
        },
        child: const Icon(Icons.explore, color: AppTheme.accent),
      ),
    );
  }
}
