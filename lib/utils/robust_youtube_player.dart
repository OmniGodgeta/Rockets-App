import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../app/theme.dart';

/// A YouTube video that plays inside the app.
///
/// Loads YouTube's own embed page straight into a WebView, sending the app as
/// the HTTP Referer. YouTube refuses embeds that don't identify the embedding
/// app: without the Referer every video fails with "Video player configuration
/// error" (153), and youtube_player_iframe's HTML wrapper, which sends
/// youtube.com itself as the origin, fails with 152-4. That was why Space Live
/// and Rocket History always fell back to "Open in YouTube" (re-diagnosed
/// 2026-10-02 on an emulator, reading the player's own error text).
///
/// Falls back to an "Open in YouTube" button only when the embed page itself
/// shows a YouTube error.
class RobustYoutubePlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final double aspectRatio;
  final double startSeconds;

  const RobustYoutubePlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.aspectRatio = 16 / 9,
    this.startSeconds = 0,
  });

  /// Identifies this app to YouTube; must be an https origin.
  static const referer = 'https://com.shadowswords.rockets/';

  @override
  State<RobustYoutubePlayer> createState() => _RobustYoutubePlayerState();
}

class _RobustYoutubePlayerState extends State<RobustYoutubePlayer> {
  late final WebViewController _controller;
  bool _failed = false;
  bool _fullscreenOpen = false;

  Uri get _embedUri =>
      Uri.https('www.youtube.com', '/embed/${widget.videoId}', {
        'playsinline': '1',
        'rel': '0',
        if (widget.autoPlay) 'autoplay': '1',
        if (widget.startSeconds > 0) 'start': '${widget.startSeconds.round()}',
      });

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _checkForError(),
        // Links inside the player (title, "Watch on YouTube", channel) open
        // the YouTube app instead of replacing the player.
        onNavigationRequest: (req) {
          final uri = Uri.parse(req.url);
          if (!req.isMainFrame || uri.path.startsWith('/embed/')) {
            return NavigationDecision.navigate;
          }
          launchUrl(uri, mode: LaunchMode.externalApplication);
          return NavigationDecision.prevent;
        },
      ));
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
      platform.setCustomWidgetCallbacks(
        onShowCustomWidget: _showFullscreen,
        onHideCustomWidget: () {
          if (_fullscreenOpen && mounted) Navigator.of(context).pop();
        },
      );
    }
    _controller.loadRequest(_embedUri,
        headers: const {'Referer': RobustYoutubePlayer.referer});
  }

  /// YouTube's fullscreen button hands us the video as a native view.
  Future<void> _showFullscreen(Widget video, void Function() onHidden) async {
    _fullscreenOpen = true;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => Scaffold(backgroundColor: Colors.black, body: video),
    ));
    // Reached by the back button or by YouTube's own exit-fullscreen.
    _fullscreenOpen = false;
    onHidden();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([]);
  }

  /// YouTube renders its errors in-page (`.ytp-error`); give it a few seconds
  /// to initialise, then look.
  Future<void> _checkForError() async {
    await Future<void>.delayed(const Duration(seconds: 4));
    if (!mounted || _failed) return;
    try {
      final hasError = await _controller.runJavaScriptReturningResult(
          "document.querySelector('.ytp-error') !== null");
      if (hasError.toString() == 'true' && mounted) {
        setState(() => _failed = true);
      }
    } catch (_) {}
  }

  Future<void> _openInYoutube() async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=${widget.videoId}');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open YouTube')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_disabled,
                  color: AppTheme.textSecondary, size: 40),
              const SizedBox(height: 12),
              const Text(
                "Couldn't play this video here.",
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openInYoutube,
                icon: const Icon(Icons.open_in_new),
                label: const Text('OPEN IN YOUTUBE'),
              ),
            ],
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: WebViewWidget(controller: _controller),
    );
  }
}
