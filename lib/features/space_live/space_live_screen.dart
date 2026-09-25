import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../utils/robust_youtube_player.dart';

/// Full-screen live Earth/ISS video feed.
///
/// NASA's original HDEV (High Definition Earth Viewing) experiment - what
/// the operator asked for by name - stopped transmitting in July 2019 and
/// was formally retired that August; there is no HDEV feed left to embed.
/// Its official successor is NASA's own ongoing live HD stream from an
/// external ISS camera, so that's what this screen shows.
///
/// Uses RobustYoutubePlayer (lib/utils/robust_youtube_player.dart), which
/// falls back to an "Open in YouTube" button on any playback failure - the
/// operator hit a playback error on-device that didn't match any of the
/// documented YouTube IFrame API error codes, which couldn't be reproduced
/// or root-caused further without a physical device to test on.
///
/// Note on ads: this is a real, official NASA-run YouTube stream (video id
/// awQzjn72bI0, "Live High-Definition Views from the International Space
/// Station"). Whether YouTube shows an ad before it plays is controlled by
/// YouTube/the channel at the player level and can't be suppressed from an
/// embed - unlike Weather Radar and ISS Live Now, this screen can't be made
/// fully native without standing up our own video relay, so it isn't a
/// "0 ads" guarantee the way those two are.
class SpaceLiveScreen extends StatelessWidget {
  const SpaceLiveScreen({super.key});

  static const _videoId = 'awQzjn72bI0';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('SPACE LIVE'),
        backgroundColor: Colors.black,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: const Column(
        children: [
          Expanded(
            child: Center(
              child: RobustYoutubePlayer(videoId: _videoId, autoPlay: true),
            ),
          ),
          Padding(
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
