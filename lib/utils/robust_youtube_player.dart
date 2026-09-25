import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../app/theme.dart';

/// A YouTube embed that never gets stuck on a dead/broken player. Wraps
/// youtube_player_iframe (the fix for the old raw-WebView error-153 issue),
/// but adds real failure handling: both the IFrame API's own numbered
/// errors (`controller.listen`, `value.error`) and raw WebView-level
/// failures (`onWebResourceError`, which the `.fromVideoId` factory this
/// screen used before does NOT expose) are watched. Either one swaps the
/// player out for a plain "Open in YouTube" button instead of leaving a
/// frozen or errored embed on screen - the operator hit a playback failure
/// that didn't match any of the IFrame API's documented codes (2, 5, 100,
/// 101, 105, 150), which could not be reproduced or diagnosed further
/// without a physical device, so this is a defensive fallback rather than a
/// confirmed root-cause fix.
class RobustYoutubePlayer extends StatefulWidget {
  final String videoId;
  final bool autoPlay;
  final double aspectRatio;

  const RobustYoutubePlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
    this.aspectRatio = 16 / 9,
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
      onWebResourceError: (_) {
        if (mounted) setState(() => _failed = true);
      },
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
      _controller.loadVideoById(videoId: widget.videoId);
    } else {
      _controller.cueVideoById(videoId: widget.videoId);
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
