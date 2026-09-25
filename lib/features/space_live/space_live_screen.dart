import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

/// Full-screen live Earth/ISS video feed.
///
/// NASA's original HDEV (High Definition Earth Viewing) experiment - what
/// the operator asked for by name - stopped transmitting in July 2019 and
/// was formally retired that August; there is no HDEV feed left to embed.
/// Its official successor is NASA's own ongoing live HD stream from an
/// external ISS camera, so that's what this screen shows.
///
/// Note on ads: this is a real, official NASA-run YouTube stream (video id
/// awQzjn72bI0, "Live High-Definition Views from the International Space
/// Station"), embedded via youtube-nocookie.com with related videos and
/// branding suppressed. Whether YouTube shows an ad before it plays is
/// controlled by YouTube/the channel at the player level and can't be
/// suppressed from an embed - unlike Weather Radar and ISS Live Now, this
/// screen can't be made fully native without standing up our own video
/// relay, so it isn't a "0 ads" guarantee the way those two are.
class SpaceLiveScreen extends StatefulWidget {
  const SpaceLiveScreen({super.key});

  @override
  State<SpaceLiveScreen> createState() => _SpaceLiveScreenState();
}

class _SpaceLiveScreenState extends State<SpaceLiveScreen> {
  static const _videoId = 'awQzjn72bI0';
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(
          'https://www.youtube-nocookie.com/embed/$_videoId?autoplay=1&playsinline=1&rel=0&modestbranding=1'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('SPACE LIVE'),
        backgroundColor: Colors.black,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Official NASA live views from the International Space Station.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
