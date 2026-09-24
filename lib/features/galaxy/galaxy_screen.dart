import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

/// "Galaxy" tab: an interactive 3D map of the Milky Way (spiral arms,
/// galactic core, nebulae, star clusters, Local Group), same embedded-webview
/// pattern as the Solar System tab.
class GalaxyScreen extends StatefulWidget {
  const GalaxyScreen({super.key, this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  @override
  State<GalaxyScreen> createState() => _GalaxyScreenState();
}

class _GalaxyScreenState extends State<GalaxyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..loadRequest(Uri.parse('https://www.galacticresource.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GALAXY'),
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
