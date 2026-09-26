import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../app/theme.dart';

/// A YouTube embed that never gets stuck on a dead/broken player. Wraps
/// youtube_player_iframe, falling back to a plain "Open in YouTube" button
/// only on the IFrame API's own numbered errors (`controller.listen`,
/// `value.error` - the real, video-specific failure signal: 2, 5, 100, 101,
/// 105, 150).
///
/// An earlier version of this widget ALSO treated any raw
/// `onWebResourceError` as fatal. That was itself the bug the operator hit
/// ("both sections only show Open in YouTube, can't play here") - a
/// WebView loading YouTube's embed page routinely hits benign sub-resource
/// errors (blocked ad/analytics requests, a missing favicon, etc.)
/// completely unrelated to whether the video itself plays, and treating
/// every one of those as fatal meant the fallback fired almost
/// immediately, every time, regardless of whether the video ever actually
/// had a chance to play. Removed - only `value.error` triggers the
/// fallback now.
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

  @override
  State<RobustYoutubePlayer> createState() => _RobustYoutubePlayerState();
}

class _RobustYoutubePlayerState extends State<RobustYoutubePlayer> {
  late final YoutubePlayerController _controller;
  late final StreamSubscription<YoutubePlayerValue> _valueSubscription;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
      ),
    );
    _valueSubscription = _controller.listen((value) {
      if (value.error != YoutubeError.none && mounted) {
        setState(() => _failed = true);
      }
    });
    if (widget.autoPlay) {
      _controller.loadVideoById(
          videoId: widget.videoId, startSeconds: widget.startSeconds);
    } else {
      _controller.cueVideoById(
          videoId: widget.videoId, startSeconds: widget.startSeconds);
    }
  }

  @override
  void dispose() {
    _valueSubscription.cancel();
    _controller.close();
    super.dispose();
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
      child: YoutubePlayer(controller: _controller),
    );
  }
}
