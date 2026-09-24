/// 
/// Repository pattern implementation for launch data
/// Abstracts data source layer and provides unified interface
/// 
/// @author Hermes Agent Team
/// @date 2026-09-23
///

import 'package:dio/dio.dart';

/// Abstract repository for launches
abstract class LaunchRepository {
  /// Get all launches
  Future<List<Launch>> getLaunches({
    int limit = 50,
    int skip = 0,
  });

  /// Get launch by ID
  Future<Launch?> getLaunchById(String id);

  /// Get upcoming launches only
  Future<List<Launch>> getUpcomingLaunches({int limit = 10});

  /// Get past launches only
  Future<List<Launch>> getPastLaunches({int limit = 10});

  /// Get live launches (within 1 hour of launch)
  Future<List<Launch>> getLiveLaunches({int limit = 10});

  /// Get today's launches
  Future<List<Launch>> getTodaysLaunches();

  /// Get launches near location
  Future<List<Launch>> getLaunchesNearLocation({
    double latitude,
    double longitude,
    double radiusKm = 1500,
  });

  /// Cancel a launch
  Future<bool> cancelLaunch(String launchId, {String reason});
  
  /// Subscribe to launch updates
  Future<void> subscribeToLaunchUpdates();
  
  /// Unsubscribe from updates
  Future<void> unsubscribeFromUpdates();
}

/// Repository for launch providers
abstract class ProviderRepository {
  /// Get all launch providers
  Future<List<LaunchProvider>> getProviders();

  /// Get provider by ID
  Future<LaunchProvider?> getProviderById(String id);

  /// Get providers by country/region
  Future<List<LaunchProvider>> getProvidersByRegion(String region);

  /// Search providers
  Future<List<LaunchProvider>> searchProviders(String query);

  /// Get provider statistics
  Future<Map<String, dynamic>> getProviderStats(String providerId);

  /// Check API availability
  Future<bool> checkProviderApi(String providerId);
}

/// Repository for rockets
abstract class RocketRepository {
  /// Get all rockets
  Future<List<Rocket>> getRockets();

  /// Get rocket by ID
  Future<Rocket?> getRocketById(String id);

  /// Search rockets
  Future<List<Rocket>> searchRockets(String query);

  /// Get rockets by manufacturer
  Future<List<Rocket>> getRocketsByManufacturer(String manufacturer);
}

/// Repository for video streams
abstract class StreamRepository {
  /// Get streams for launch
  Future<List<VideoStream>> getStreamsForLaunch(String launchId);

  /// Get YouTube streams
  Future<List<VideoStream>> getYouTubeStreams(String launchId);

  /// Get Planetary Radio streams
  Future<List<VideoStream>> getPlanetaryStreams({String launchId?});

  /// Get fallback streams
  Future<List<VideoStream>> getFallbackStreams();

  /// Check stream availability
  Future<bool> isStreamAvailable(String streamId);

  /// Get stream quality
  Future<String?> getStreamQuality(String streamId);
}

/// Repository for orbit data
abstract class OrbitRepository {
  /// Calculate orbital trajectory
  Future<Orbit> calculateTrajectory({
    required double latitude,
    required double longitude,
    required double velocity,
  });

  /// Get orbit classification
  Future<OrbitPeriod> classifyOrbit({
    required double altitudeMin,
    required double altitudeMax,
    required double inclination,
  });

  /// Get satellite positions
  Future<List<OrbitalPosition>> getSatellitePositions();
}

/// Base concrete repository implementation
class LaunchRepositoryImpl implements LaunchRepository {
  final DataSourceConfig sources;
  final CacheManager cache;

  LaunchRepositoryImpl({
    required this.sources,
    required this.cache,
  });

  @override
  Future<List<Launch>> getLaunches({int limit = 50, int skip = 0}) async {
    try {
      // Check cache first
      final cached = await cache.getLaunches(skip: skip, limit: limit);
      if (cached != null) return cached;

      // Fetch from primary source
      final launches = await sources.fetchLaunches(limit: limit, skip: skip);
      
      // Cache results
      await cache.setLaunches(launches, skip: skip, limit: limit);
      return launches;
    } catch (e) {
      throw DataFetchingException.fromCause('Failed to fetch launches', e);
    }
  }

  @override
  Future<Launch?> getLaunchById(String id) async {
    try {
      final cached = await cache.getLaunchById(id);
      if (cached != null) return cached;

      final launch = await sources.fetchLaunch(id);
      if (launch != null && launch.id == id) {
        await cache.setLaunch(launch, id: id);
        return launch;
      }
      return null;
    } catch (e) {
      // Try alternative sources if primary fails
      if (sources.primaryApi != null) {
        try {
          final altLaunch = await sources.primaryApi!.fetchLaunch(id);
          await cache?.setLaunch(altLaunch, id: id);
          return altLaunch;
        } catch (_) {
          return null;
        }
      }
      throw DataFetchingException('Launch not found: $id');
    }
  }

  @override
  Future<List<Launch>> getUpcomingLaunches({int limit = 10}) async {
    final now = DateTime.now();
    final allLaunches = await getLaunches(limit: limit + 10);
    return allLaunches.where((launch) => launch.isUpcoming).take(limit).toList();
  }

  @override
  Future<List<Launch>> getPastLaunches({int limit = 10}) async {
    final allLaunches = await getLaunches(limit: limit + 10);
    return allLaunches.where((launch) => launch.isPast).take(limit).toList();
  }

  @override
  Future<List<Launch>> getLiveLaunches({int limit = 10}) async {
    final allLaunches = await getLaunches(limit: limit + 10);
    return allLaunches.where((launch) => launch.isLive).take(limit).toList();
  }

  @override
  Future<List<Launch>> getTodaysLaunches() async {
    final now = DateTime.now();
    final allLaunches = await getLaunches(limit: 20);
    return allLaunches.where((launch) {
      final launchDate = DateTime(
        launch.date.year,
        launch.date.month,
        launch.date.day,
      );
      return launchDate == now;
    }).toList();
  }

  @override
  Future<List<Launch>> getLaunchesNearLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 1500,
  }) async {
    final allLaunches = await getLaunches(limit: 100);
    return allLaunches.where((launch) {
      final site = launch.location;
      final distance = calculateDistance(
        site.lat,
        site.lon,
        latitude,
        longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  @override
  Future<bool> cancelLaunch(String launchId, {String? reason}) async {
    // Not implemented for public API
    return false;
  }

  @override
  Future<void> subscribeToLaunchUpdates() async {
    // Implement real-time subscription if needed
    // Could use WebSocket or polling
  }

  @override
  Future<void> unsubscribeFromUpdates() async {
    // Cancel subscriptions
  }
}

/// Repository for data fetching utilities
class DataFetchingException implements Exception {
  final String message;
  final Exception? cause;

  DataFetchingException(this.message, {this.cause});

  factory DataFetchingException.fromCause(String original, Exception cause) {
    return DataFetchingException('Original: $original\nActual: $cause', cause: cause);
  }
}

/// Cache manager for offline support
class CacheManager {
  final String cacheKeyPrefix;
  
  /// Check if data is cached
  bool isDataCached(String key);
  
  /// Get data from cache
  T? getCacheData<T>(String key);
  
  /// Set data in cache
  Future<void> setCacheData<T>(String key, T data);
  
  /// Clear all cached data
  Future<void> clearCache();
  
  /// Invalidate a specific key
  Future<void> invalidate(String key);

  CacheManager({String cacheKeyPrefix = 'rocket_app'});
}

/// HTTP service wrapper
class ApiService {
  final Dio dio;
  final DataSource config;

  ApiService({
    required this.dio,
    required this.config,
  });

  /// Make HTTP request
  Future<Map<String, dynamic>> fetch(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw DataFetchingException('Failed to fetch $endpoint: $e');
    }
  }

  /// Fetch launches endpoint
  Future<List<Launch>> fetchLaunches({int limit = 50, int skip = 0}) async {
    try {
      final response = await dio.get('/v4/launches/past', queryParameters: {
        'limit': limit,
      });
      return (response.data as List).map((json) => Launch.fromJson(json)).toList();
    } catch (e) {
      return [];  // Return empty instead of throwing
    }
  }

  /// Fetch single launch
  Future<Launch?> fetchLaunch(String id) async {
    try {
      final response = await dio.get('/launches/$id');
      return Launch.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}

/// Create repositories with dependencies
class Repositories {
  static final DataSourceConfig _sources = DataSourceConfig();
  static final CacheManager _cache = CacheManager();
  static final ApiService _api = ApiService(
    dio: Dio(),
    config: _sources,
  );
  
  static LaunchRepository get launches => LaunchRepositoryImpl(
        sources: _sources,
        cache: _cache,
      );
  
  static ProviderRepository get providers => ProviderRepositoryImpl();
  
  static RocketRepository get rockets => RocketRepositoryImpl();
  
  static StreamRepository get streams => StreamRepositoryImpl();
  
  static OrbitRepository get orbits => OrbitRepositoryImpl();
}
