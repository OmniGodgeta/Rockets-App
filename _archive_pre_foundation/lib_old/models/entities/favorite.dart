import 'package:flutter/foundation.dart';

/// FAVORITES entity for bookmarking launches
class FavoriteLaunch {
  /// Favorite identifier
  final String id;
  
  /// Launch ID
  final String launchId;
  
  /// Launch name
  final String launchName;
  
  /// Note
  final String? note;
  
  /// Priority (higher = more important)
  @JsonKey(name: 'priority')
  final int? priority;
  
  /// Rating (1-5 stars)
  @JsonKey(name: 'rating')
  final int? rating;
  
  /// Date added
  @JsonKey(name: 'created')
  final DateTime? created;
  
  /// Is this favorite?
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  
  /// Category
  @JsonKey(name: 'category')
  final String? category;

  FavoriteLaunch({
    this.id = '',
    required this.launchId,
    required this.launchName,
    this.note,
    this.priority,
    this.rating,
    this.created,
    this.isFavorite = false,
    this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteLaunch && runtimeType == other.runtimeType &&
      id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Location permission status
class LocationPermission {
  final LocationPermissionStatus status;
  final String? message;

  LocationPermission({
    this.status = LocationPermissionStatus.denied,
    this.message,
  });

  factory LocationPermission.notDetermined() {
    return LocationPermission(status: LocationPermissionStatus.notDetermined);
  }

  factory LocationPermission.enabled() {
    return LocationPermission(status: LocationPermissionStatus.enabled);
  }

  factory LocationPermission.denied() {
    return LocationPermission(status: LocationPermissionStatus.denied);
  }
}

/// Location permission status
enum LocationPermissionStatus {
  enabled,
  disabled,
  denied,
  neverAsked,
  notDetermined,
}

/// Theme configuration
class ThemeConfig {
  final bool isDark;
  final bool usesSystemTheme;
  final bool showLaunchNotifications;
  final bool showVideoControls;
  final String selectedLocale;
  final bool enableAnimation;

  ThemeConfig({
    this.isDark = true,
    this.usesSystemTheme = true,
    this.showLaunchNotifications = true,
    this.showVideoControls = true,
    this.selectedLocale = 'en',
    this.enableAnimation = true,
  });

  factory ThemeConfig.fromSystem({bool useSystem = true}) {
    final brightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
    return ThemeConfig(
      isDark: brightness == Brightness.dark,
      usesSystemTheme: useSystem,
    );
  }
}

/// Launch filter criteria
class LaunchFilter {
  final List<LaunchProviderFilter> providers;
  final List<String> countries;
  final List<RocketFilter> rockets;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<OrbitTypeFilter> orbitTypes;
  final bool includePast;
  final bool includeScheduled;
  final String? searchQuery;
  final SortOrder sortOrder;

  LaunchFilter({
    this.providers = const [],
    this.countries = const [],
    this.rockets = const [],
    this.fromDate,
    this.toDate,
    this.orbitTypes = const [],
    this.includePast = true,
    this.includeScheduled = true,
    this.searchQuery = '',
    this.sortOrder = SortOrder.date,
  });

  /// Empty filter showing all launches
  factory LaunchFilter.empty() {
    return LaunchFilter(
      includePast: true,
      includeScheduled: true,
    );
  }
}

/// Launch provider filter
class LaunchProviderFilter {
  final String id;
  final bool includeAll;
  final String? name;

  LaunchProviderFilter({
    this.id = 'all',
    this.includeAll = false,
    this.name,
  }) : if (id == 'all') includeAll = true else id = id;

  bool get isActive => !includeAll;
}

/// Sort order
enum SortOrder {
  dateDescending,  // Newest first
  dateAscending,   // Oldest first  
  nameAscending,   // A-Z
  providerAscending,
}

/// Rocket filter
class RocketFilter {
  final String? id;
  final bool? isActive;

  RocketFilter({this.id, this.isActive});
}

/// Orbit type filter
enum OrbitTypeFilter {
  lEO,
  mEO,
  hEO,
  gEO,
  pOLAR,
  all;

  String get label {
    switch (this) {
      case OrbitTypeFilter.lEO: return 'LEO';
      case OrbitTypeFilter.mEO: return 'MEO';
      case OrbitTypeFilter.hEO: return 'HEO';
      case OrbitTypeFilter.gEO: return 'GEO';
      case OrbitTypeFilter.pOLAR: return 'Polar';
      case OrbitTypeFilter.all: return 'All';
    }
  }
}

/// Mission timeline event
class TimelineEvent {
  /// Unique event identifier
  final String id;
  
  /// Event timestamp
  @JsonKey(name: 'timestamp')
  final DateTime timestamp;
  
  /// Event type
  @JsonKey(name: 'event_type')
  final String eventType;
  
  /// Event name/title
  final String name;
  
  /// Event description
  final String? description;
  
  /// Video stream URL (if applicable)
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  
  final bool isCritical;

  TimelineEvent({
    this.id = '',
    required this.timestamp,
    required this.eventType,
    required this.name,
    this.description,
    this.videoUrl,
    this.isCritical = false,
  });

  factory TimelineEvent.countdown(int minutes) {
    return TimelineEvent(
      id: 'countdown',
      timestamp: DateTime.now().add(Duration(minutes: minutes)),
      eventType: 'countdown',
      name: '$minutes minutes to launch',
      isCritical: minutes == 0,
    );
  }

  factory TimelineEvent.launch() {
    return TimelineEvent(
      id: 'launch',
      timestamp: DateTime.now(),
      eventType: 'launch',
      name: 'Lift-off',
    );
  }

  factory TimelineEvent.payload() {
    return TimelineEvent(
      id: 'payload',
      timestamp: DateTime.now().add(Duration(minutes: 5)),
      eventType: 'payload',
      name: 'Payload deployment',
    );
  }
}
