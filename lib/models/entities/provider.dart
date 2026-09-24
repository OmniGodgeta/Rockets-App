import 'package:flutter/foundation.dart';

/// Launch provider/agency with details
/// 
/// Represents a space launch organization from around the world
/// 
/// @author Hermes Agent Team
/// @date 2026-09-23
class LaunchProvider implements Comparable<LaunchProvider> {
  /// Unique provider ID
  final String id;
  
  /// Provider name
  final String name;
  
  /// Official abbreviation
  @JsonKey(name: 'abbreviation')
  final String? abbreviation;
  
  /// Short name
  @JsonKey(name: 'short_name')
  final String? shortName;
  
  /// Country/region code
  @JsonKey(name: 'country_code')
  final String? countryCode;
  
  /// Full country name
  final String? country;
  
  /// Launch success rate (0.0 to 1.0)
  @JsonKey(name: 'success_rate')
  final double? successRate;
  
  /// First launch date
  final DateTime? firstLaunch;
  
  /// Launches completed
  @JsonKey(name: 'launches')
  final int? launches;
  
  /// Failed launches
  @JsonKey(name: 'failures')
  final int? failures;
  
  /// Provider logo URL
  final String? logoUri;
  
  /// Website URL
  @JsonKey(name: 'website')
  final String? website;
  
  /// Description
  final String description;
  
  /// Headquarters location
  @JsonKey(name: 'headquarters')
  final String? headquarters;
  
  /// Status (active, inactive, historical)
  @JsonKey(name: 'status')
  final String status;
  
  /// Launch capabilities
  final List<String> capabilities;
  
  /// Known launch sites
  final List<String> launchSites;
  
  /// API endpoints if available
  Map<String, String>? apiEndpoints;
  
  LaunchProvider({
    this.id = '',
    this.name = '',
    this.abbreviation,
    this.shortName,
    this.countryCode,
    this.country,
    this.successRate,
    this.firstLaunch,
    this.launches,
    this.failures,
    this.logoUri,
    this.website,
    this.description = '',
    this.headquarters,
    this.status = 'active',
    this.capabilities = const [],
    this.launchSites = const [],
    this.apiEndpoints,
  });

  /// Check if provider matches search
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
           abbreviation?.toLowerCase().contains(lowerQuery) == true ||
           description.toLowerCase().contains(lowerQuery) ||
           country?.toLowerCase().contains(lowerQuery) == true;
  }

  /// Calculate success rate from launches/failures
  double get computedSuccessRate {
    if (launches == null) return 1.0;
    final totalFailures = (failures ?? 0).toDouble();
    return (1.0 - (totalFailures / launches!));
  }

  /// Get formatted stats string
  String get statsString {
    if (launches != null && failures != null) {
      return '${launches!} launches, ${failures!} failures, '
          '$successRate% success';
    }
    return '$name';
  }

  /// Get status badge
  String get statusBadge {
    switch (status.toLowerCase()) {
      case 'active': return '✅ Active';
      case 'inactive': return '🔴 Inactive';
      case 'historical': return '📜 Historical';
      default: return '❓ Unknown';
    }
  }

  /// Check if provider is international (non-US)
  bool get isInternational {
    return ['CN', 'RU', 'IN', 'JP', 'EU', 'FR', 'DE', 'IT'].contains(
        countryCode);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaunchProvider && runtimeType == other.runtimeType &&
      id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  int compareTo(LaunchProvider other) {
    return name.compareTo(other.name);
  }
}

/// API data source configuration
class DataSource {
  final String id;
  final String name;
  final String baseUri;
  final bool isActive;
  final int priority;  // Higher = preferential
  final bool requiresAuth;
  final String authType;  // api_key, oAuth, none
  final String description;

  DataSource({
    required this.id,
    required this.name,
    this.baseUri = '',
    this.isActive = true,
    this.priority = 0,
    this.requiresAuth = false,
    this.authType = 'none',
    this.description = '',
  });

  factory DataSource.spacex() {
    return DataSource(
      id: 'spacex',
      name: 'SpaceX API',
      baseUri: 'https://api.spacexdata.com/v4',
      isActive: true,
      priority: 100,
      requiresAuth: false,
      authType: 'none',
      description: 'Primary SpaceX launch manifest API',
    );
  }

  factory DataSource.nasa() {
    return DataSource(
      id: 'nasa',
      name: 'NASA APIs',
      baseUri: 'https://api.nasa.gov',
      isActive: true,
      priority: 90,
      requiresAuth: true,
      authType: 'api_key',
      description: 'NASA planetary data and mission info',
    );
  }

  factory DataSource.rocketLab() {
    return DataSource(
      id: 'rocket_lab',
      name: 'Rocket Lab',
      baseUri: 'https://api.rocketlabusa.com',
      isActive: true,
      priority: 80,
      requiresAuth: false,
      authType: 'none',
      description: 'Rocket Lab manifest data',
    );
  }

  factory DataSource.isro() {
    return DataSource(
      id: 'isro',
      name: 'ISRO',
      baseUri: 'https://isro.gov.in',
      isActive: true,
      priority: 70,
      requiresAuth: false,
      authType: 'none',
      description: 'Indian Space Research Organisation',
    );
  }

  factory DataSource.esa() {
    return DataSource(
      id: 'esa',
      name: 'ESA',
      baseUri: 'https://esa.int',
      isActive: true,
      priority: 65,
      requiresAuth: false,
      authType: 'none',
      description: 'European Space Agency',
    );
  }

  factory DataSource.jaxa() {
    return DataSource(
      id: 'jaxa',
      name: 'JAXA',
      baseUri: 'https://jaxa.jp',
      isActive: true,
      priority: 60,
      requiresAuth: false,
      authType: 'none',
      description: 'Japan Aerospace Exploration Agency',
    );
  }

  factory DataSource.cnsa() {
    return DataSource(
      id: 'cnsa',
      name: 'CNSA',
      baseUri: 'https://cnsa.gov.cn',
      isActive: true,
      priority: 55,
      requiresAuth: false,
      authType: 'none',
      description: 'China National Space Administration',
    );
  }

  factory DataSource.planetaryRadio() {
    return DataSource(
      id: 'planetary_radio',
      name: 'Planetary Radio',
      baseUri: 'https://www.planetaryradio.com',
      isActive: true,
      priority: 40,
      requiresAuth: false,
      authType: 'none',
      description: 'Live streaming from all missions',
    );
  }

  factory DataSource.youtube() {
    return DataSource(
      id: 'youtube',
      name: 'YouTube API',
      baseUri: 'https://www.googleapis.com/youtube/v3',
      isActive: true,
      priority: 85,
      requiresAuth: false,
      authType: 'api_key',
      description: 'Launch video streams and official content',
    );
  }

  factory DataSource.spaceLaunchReport() {
    return DataSource(
      id: 'slr',
      name: 'Space Launch Report',
      baseUri: 'https://space-launch-report.com',
      isActive: true,
      priority: 50,
      requiresAuth: false,
      authType: 'none',
      description: 'International launch manifest data',
    );
  }
}

/// Extension for provider stats
extension LaunchProviderStats on LaunchProvider {
  String get successRateFormatted {
    if (successRate == null) return 'N/A';
    if (successRate == 1.0) return '100%';
    if (successRate == 0.0) return '0%';
    return '${(successRate! * 100).toInt()}%';
  }
}

/// Extension for data sources
extension DataSourceExtension on DataSource {
  String get statusIcon {
    if (!isActive) return '🔴';
    return isActive && priority > 80 ? '🟢' : '🟡';
  }
}
