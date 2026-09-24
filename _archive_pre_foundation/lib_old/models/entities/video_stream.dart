import 'package:flutter/foundation.dart';

/// Video stream information for a launch
/// 
/// Manages multiple stream sources with fallback capability
/// 
/// @author Hermes Agent Team
/// @date 2026-09-23
class VideoStream {
  /// Primary video source
  final String sourceId;
  
  /// Stream URL
  final String streamUrl;
  
  /// Embed URL for iFrames
  @JsonKey(name: 'embed_url')
  final String? embedUrl;
  
  /// YouTube video ID (if applicable)
  @JsonKey(name: 'youtube_id')
  final String? youtubeId;
  
  /// Stream title
  final String title;
  
  /// Stream provider
  final String provider;
  
  /// Stream quality options
  final List<StreamQuality> qualities;
  
  /// Current quality (highest available)
  @JsonKey(name: 'current_quality')
  final String? currentQuality;
  
  /// Is this stream active/live
  final bool isLive;
  
  /// Stream status
  @JsonKey(name: 'status')
  final StreamStatus status;
  
  /// Whether to show the stream
  final bool isAvailable;
  
  /// Stream metadata
  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;
  
  /// Thumbnail or poster image
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;
  
  VideoStream({
    this.sourceId = '',
    this.streamUrl = '',
    this.embedUrl,
    this.youtubeId,
    this.title = '',
    this.provider = '',
    this.qualities = const [],
    this.currentQuality,
    this.isLive = false,
    this.status = StreamStatus.unknown,
    this.isAvailable = false,
    this.metadata,
    this.thumbnail,
  });

  /// Create from launch provider stream
  factory VideoStream.fromProvider(
    String title,
    String streamUrl, {
    StreamStatus status = StreamStatus.live,
    List<StreamQuality> qualities = const [],
  }) {
    return VideoStream(
      sourceId: 'provider_stream',
      streamUrl: streamUrl,
      title: title,
      provider: 'Provider',
      isLive: status == StreamStatus.live,
      isAvailable: true,
      status: status,
      qualities: qualities,
    );
  }

  /// Create from YouTube video
  factory VideoStream.fromYouTube(String youtubeId, String title) {
    return VideoStream(
      sourceId: 'youtube',
      streamUrl: 'https://www.youtube.com/watch?v=$youtubeId',
      youtubeId: youtubeId,
      title: title,
      provider: 'YouTube',
      isAvailable: youtubeId.isNotEmpty,
    );
  }

  /// Create from Planetary Radio
  factory VideoStream.fromPlanetary(String title) {
    return VideoStream(
      sourceId: 'planetary_radio',
      streamUrl: 'https://www.planetaryradio.com',
      title: title,
      provider: 'Planetary Radio',
    );
  }

  /// Create fallback stream
  factory VideoStream.fallback(String title) {
    return VideoStream(
      sourceId: 'fallback',
      streamUrl: '',
      title: title,
      provider: 'Unavailable',
      isLive: false,
      isAvailable: false,
      status: StreamStatus.unavailable,
    );
  }
}

/// Stream quality levels
enum StreamQuality {
  low('480p', 480, const Color(0xFF00A1DE)),
  medium('720p', 720, const Color(0xFF00A1DE)),
  high('1080p', 1080, const Color(0xFF00A1DE)),
  auto('Auto', 0, const Color(0xFF808080));

  final String label;
  final int resolution;
  final Color color;

  const StreamQuality(this.label, this.resolution, this.color);
}

/// Stream status enum
enum StreamStatus {
  active('🔴 Live'),
  ended('📄 Ended'),
  liveNow('🔴 Live Now'),
  scheduled('📅 Scheduled'),
  unavailable('❌ Unavailable'),
  paused('⏸️ Paused'),
  buffering('🔄 Buffering'),
  error('⚠️ Error'),
  unknown('❓ Unknown');

  final String badge;

  const StreamStatus(this.badge);

  String get statusText {
    switch (this) {
      case StreamStatus.active:
        return 'Active';
      case StreamStatus.ended:
        return 'Ended';
      case StreamStatus.liveNow:
        return 'Live';
      case StreamStatus.scheduled:
        return 'Scheduled';
      case StreamStatus.unavailable:
        return 'Unavailable';
      case StreamStatus.paused:
        return 'Paused';
      case StreamStatus.buffering:
        return 'Buffering';
      case StreamStatus.error:
        return 'Error';
      case StreamStatus.unknown:
        return 'Unknown';
    }
  }
}

/// Launch video stream collection
class LaunchStreams {
  final List<VideoStream> streams;
  final String primaryStreamId;
  final String launchId;

  LaunchStreams({
    required this.streams,
    required this.primaryStreamId,
    required this.launchId,
  });

  /// Get primary stream
  VideoStream get primary => streams.firstWhere(
        (s) => s.sourceId == primaryStreamId,
        orElse: () => VideoStream.fallback('No stream available'),
      );

  /// Get best quality stream
  VideoStream get bestQuality => streams.fold(
        VideoStream.fallback('No streams available'),
        (best, current) {
          final currentQual = StreamQuality.values
              .firstWhere(
                (q) => current.qualities.contains(q),
                orElse: () => StreamQuality.auto,
              );
          final bestQual = StreamQuality.values
              .firstWhere(
                (q) => best.qualities.contains(q),
                orElse: () => StreamQuality.auto,
              );
          return currentQual.resolution > bestQual.resolution ? current : best;
        },
      );

  /// Switch to specified stream
  VideoStream? switchTo(String streamId) {
    return streams.firstWhere(
      (s) => s.sourceId == streamId,
      orElse: () => VideoStream.fallback('Stream not found'),
    );
  }
}

/// Stream provider configuration
class StreamProvider {
  final String id;
  final String name;
  final String iconPath;
  final bool isPreferred;
  final List<StreamUrlPattern> urlPatterns;

  StreamProvider({
    required this.id,
    required this.name,
    this.iconPath = 'assets/icons/provider_default.png',
    this.isPreferred = true,
    List<StreamUrlPattern>? urlPatterns,
  }) : urlPatterns = urlPatterns ?? [
          StreamUrlPattern(youtube: true, nasa: false),
          StreamUrlPattern(planetary: true),
        ];
}

/// Stream URL pattern matcher
class StreamUrlPattern {
  final bool youtube;
  final bool vimeo;
  final bool nasa;
  final bool planetary;
  final String? customDomain;

  StreamUrlPattern({
    this.youtube = false,
    this.vimeo = false,
    this.nasa = false,
    this.planetary = false,
    this.customDomain,
  });
}

/// Stream quality selection state
class QualitySelector {
  final int selectedQualityIndex;
  final String selectedQualityLabel;
  final String selectedQualityResolution;

  QualitySelector({
    required this.selectedQualityIndex,
    required this.selectedQualityLabel,
    required this.selectedQualityResolution,
  });

  factory QualitySelector.fromStream(VideoStream stream) {
    final index = stream.qualities.length - 1;
    final quality = stream.qualities.isNotEmpty ? stream.qualities[index] : StreamQuality.auto;
    return QualitySelector(
      selectedQualityIndex: index,
      selectedQualityLabel: quality.label,
      selectedQualityResolution: quality.resolution.toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualitySelector &&
      runtimeType == other.runtimeType &&
      selectedQualityIndex == other.selectedQualityIndex;

  @override
  int get hashCode => selectedQualityIndex.hashCode;
}
