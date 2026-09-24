import 'package:flutter/material.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;

  const VideoPlayerPage({super.key, required this.videoId});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  String? _videoUrl;
  String _provider = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadVideoUrl();
  }

  Future<void> _loadVideoUrl() async {
    // Different providers have different URL patterns
    if (widget.videoId.contains('nasa')) {
      // NASA streams
      if (widget.videoId.contains('arTEMIS')) {
        _videoUrl = 'https://www.youtube.com/embed/Artemis';
        _provider = 'NASA / YouTube';
      } else {
        // Generic NASA placeholder
        _videoUrl = 'https://stream.nasatv.com/';
        _provider = 'NASA TV';
      }
    } else if (widget.videoId.contains('youtube')) {
      // Direct YouTube embed
      String? videoId;
      try {
        if (widget.videoId.contains('=')) {
          videoId = widget.videoId.split('=').last;
        } else {
          final parts = widget.videoId.split('/');
          if (parts.isNotEmpty) videoId = parts.last;
        }
        if (videoId != null && videoId.isNotEmpty) {
          _videoUrl = 'https://www.youtube.com/embed/$videoId';
          _provider = 'YouTube';
        }
      } catch (_) {}
    } else if (widget.videoId.contains('rocketlab')) {
      _videoUrl = 'https://www.youtube.com/embed/RocketLabElectron';
      _provider = 'Rocket Lab';
    } else {
      // Default YouTube fallback
      _videoUrl = 'https://www.youtube.com/embed/${widget.videoId.split('=').last}';
      _provider = 'YouTube';
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎥 Live Stream'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: _videoUrl != null
            ? HtmlElementView(
                viewId: 'youtubePlayer',
                onPlatformViewCreated: () {
                  // Initialize YouTube player if needed
                },
              )
            : const Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading video stream...'),
                  ],
                ),
              ),
      ),
    );
  }
}

// Note: For production YouTube integration, use the YouTube_player package:
// - Add to pubspec.yaml: youtube_player_flutter: ^4.3.0
// - Replace HtmlElementView with Flutter YouTube player widget
// - Handle video loading, play/pause, fullscreen modes
// - Add error handling for network failures
