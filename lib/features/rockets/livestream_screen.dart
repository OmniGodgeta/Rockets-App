import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

/// Plays a launch webcast inside the app instead of handing off to an
/// external browser/app. Recognizes YouTube links (the vast majority of LL2
/// vidURLs entries) and rewrites them to an embeddable, autoplaying player;
/// anything else (e.g. the SpaceX-on-X fallback link) just loads the page
/// directly - still inside the app, even though it isn't an embeddable
/// player for that particular source.
class LivestreamScreen extends StatefulWidget {
  const LivestreamScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<LivestreamScreen> createState() => _LivestreamScreenState();
}

class _LivestreamScreenState extends State<LivestreamScreen> {
  late final WebViewController _controller;

  static String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    if (host.contains('youtube.com')) {
      if (uri.pathSegments.contains('embed')) {
        final idx = uri.pathSegments.indexOf('embed');
        if (idx + 1 < uri.pathSegments.length) return uri.pathSegments[idx + 1];
      }
      return uri.queryParameters['v'];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final youtubeId = _extractYoutubeId(widget.url);
    final loadUrl = youtubeId != null
        ? 'https://www.youtube-nocookie.com/embed/$youtubeId?autoplay=1&playsinline=1&rel=0&modestbranding=1'
        : widget.url;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(loadUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
