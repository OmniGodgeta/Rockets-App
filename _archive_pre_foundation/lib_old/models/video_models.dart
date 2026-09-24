class VideoSource {
  final String name;
  final String url;
  final bool isFallback;
  final String provider;

  // Stream quality options
  final String quality; // '1080p', '720p', '480p', 'auto'
  final String status; // 'live', 'ended', 'upcoming'

  constructor required this.name, required this.url,
      this.isFallback = false, this.provider = 'youtube',
      this.quality = 'auto', this.status = 'live'

}

class VideoStreamManager {
  final List<VideoSource> sources;
  final String currentStream;

  // Stream status
  final bool isLive;
  final bool hasError;
  final String errorMessage;

  // Switch to fallback stream
  void switchToFallback() {
    // Implement fallback logic
  }

  constructor required this.sources, this.currentStream = '',
      this.isLive = false, this.hasError = false, this.errorMessage = ''

}

class YouTubeStream {
  final String videoId;
  final int? embeddable;
  final int? liveBroadcastContent;

  constructor required this.videoId, this.embeddable, this.liveBroadcastContent

}