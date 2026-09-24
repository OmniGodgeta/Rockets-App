import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

/// "Satellites" tab: a live Starlink-map-style 3D view of every satellite in
/// orbit (https://satellitemap.space), per the operator's own request that
/// this be the reference design ("look into Starlink map ... that's the
/// design I want"), embedded directly rather than reimplemented natively.
///
/// TODO (next agent): the search bar below is a UI shell only - it does not
/// yet filter satellitemap.space's embedded view (that site has no public
/// query-string search API to drive from outside). TODO: compass/"which way
/// to look" direction-finder mode using device sensors (flutter_compass +
/// satellite TLE/orbital-position math) is not built yet - out of scope for
/// this foundation pass.
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
