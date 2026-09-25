import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../app/theme.dart';

/// Full-screen live Earth/ISS video feed.
///
/// NASA's original HDEV (High Definition Earth Viewing) experiment - what
/// the operator asked for by name - stopped transmitting in July 2019 and
/// was formally retired that August; there is no HDEV feed left to embed.
/// Its official successor is NASA's own ongoing live HD stream from an
/// external ISS camera, so that's what this screen shows.
///
/// Rebuilt on youtube_player_iframe instead of a raw WebViewController
/// pointed straight at a youtube-nocookie.com embed URL - that approach hit
/// YouTube error 153 ("requested video cannot be played in an embedded
/// player") because a bare loadRequest() never establishes a valid HTTP
/// origin for YouTube's embed-origin check the way the IFrame Player API
/// (which this package wraps correctly, including origin/enablejsapi) does.
///
/// Note on ads: this is a real, official NASA-run YouTube stream (video id
/// awQzjn72bI0, "Live High-Definition Views from the International Space
/// Station"). Whether YouTube shows an ad before it plays is controlled by
/// YouTube/the channel at the player level and can't be suppressed from an
/// embed - unlike Weather Radar and ISS Live Now, this screen can't be made
/// fully native without standing up our own video relay, so it isn't a
/// "0 ads" guarantee the way those two are.
class SpaceLiveScreen extends StatefulWidget {
  const SpaceLiveScreen({super.key});

  @override
  State<SpaceLiveScreen> createState() => _SpaceLiveScreenState();
}

class _SpaceLiveScreenState extends State<SpaceLiveScreen> {
  static const _videoId = 'awQzjn72bI0';
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
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
            child: YoutubePlayer(controller: _controller),
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
