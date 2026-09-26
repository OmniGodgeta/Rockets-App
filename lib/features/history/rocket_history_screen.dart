import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../utils/robust_youtube_player.dart';

/// A brief history of rocketry: a short native write-up plus the operator's
/// chosen reference video. Uses RobustYoutubePlayer (falls back to "Open in
/// YouTube" on any playback failure - see space_live_screen.dart for why).
class RocketHistoryScreen extends StatelessWidget {
  const RocketHistoryScreen({super.key});

  // "Escape Velocity - A Quick History of Space Exploration" (David Peterson)
  static const _videoId = 'PLcE3AI9wwE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ROCKET HISTORY')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const RobustYoutubePlayer(videoId: _videoId, startSeconds: 4),
          const SizedBox(height: 20),
          Text(
            'A BRIEF HISTORY OF ROCKETS',
            style: AppTheme.headline.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          const _HistoryParagraph(
            era: '13th century',
            text:
                'Gunpowder-propelled "fire arrows" in China are the earliest '
                'known rockets, used first as fireworks and later as simple '
                'weapons.',
          ),
          const _HistoryParagraph(
            era: '1903',
            text:
                'Russian schoolteacher Konstantin Tsiolkovsky publishes the '
                'rocket equation, showing that a multi-stage, liquid-fueled '
                'rocket could reach orbital velocity.',
          ),
          const _HistoryParagraph(
            era: '1926',
            text:
                'Robert Goddard launches the first liquid-fueled rocket in '
                'Auburn, Massachusetts - it flew for about 2.5 seconds.',
          ),
          const _HistoryParagraph(
            era: '1942-1944',
            text:
                'Germany\'s V-2, developed under Wernher von Braun, becomes '
                'the first human-made object to reach space, during a '
                'vertical test flight.',
          ),
          const _HistoryParagraph(
            era: '1957',
            text:
                'The Soviet Union launches Sputnik 1, the first artificial '
                'satellite, opening the Space Race.',
          ),
          const _HistoryParagraph(
            era: '1961',
            text:
                'Yuri Gagarin becomes the first human in space aboard '
                'Vostok 1.',
          ),
          const _HistoryParagraph(
            era: '1969',
            text:
                'NASA\'s Saturn V, still the most powerful rocket ever '
                'successfully flown, launches Apollo 11 - the first crewed '
                'Moon landing.',
          ),
          const _HistoryParagraph(
            era: '1981-2011',
            text:
                'The Space Shuttle flies 135 missions, pioneering a partially '
                'reusable spacecraft design.',
          ),
          const _HistoryParagraph(
            era: '2015',
            text:
                'SpaceX lands a Falcon 9 first stage propulsively for the '
                'first time, kicking off the era of routine reusable orbital '
                'rockets.',
          ),
          const _HistoryParagraph(
            era: 'Today',
            text:
                'SpaceX\'s Starship, Blue Origin\'s New Glenn, and other '
                'fully reusable heavy-lift rockets aim to make regular Moon '
                'and Mars missions possible.',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _HistoryParagraph extends StatelessWidget {
  final String era;
  final String text;

  const _HistoryParagraph({required this.era, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            era.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
