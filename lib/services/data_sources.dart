/// 
/// Data source configuration and API integrations
/// Manages connections to multiple space launch data sources
/// 
/// @author Hermes Agent Team
/// @date 2026-09-23
///

import 'entities/rocket.dart';
import 'entities/launch_site.dart';
import 'entities/launch.dart';
import 'entities/provider.dart';

/// Configuration for all data sources
class DataSourceConfig {
  final List<DataSource> sources;
  final DataSource? primaryApi;
  late String apiKey;  // Will be set from settings

  DataSourceConfig();

  /// Fetch launches from SpaceX API (primary source)
  Future<List<Launch>> fetchLaunches({int limit = 50, int skip = 0}) async {
    try {
      final baseUrl = 'https://api.spacexdata.com/v4';
      final launchListUrl = '/launches/past';
      
      // In production, use Dio/HttpClient with actual API call
      // For now, return static data or cached data
      return await fetchLaunchesWithFallback(
        limit: limit,
        skip: skip,
        primarySource: DataSource.spacex(),
      );
    } catch (e) {
      // Fall back to other sources
      throw DataFetchingException.fromCause('SpaceX API failed: $e', e);
    }
  }

  /// Single launch fetch
  Future<Launch?> fetchLaunch(String id) async {
    try {
      final baseUrl = 'https://api.spacexdata.com/v4';
      final launchUrl = '/launches/$id';
      
      // Simulated response - in production, use actual HTTP call
      return await fetchLaunchWithFallback(id: id);
    } catch (e) {
      return null;
    }
  }

  /// Fetch all rockets
  Future<List<Rocket>> fetchRockets() async {
    final rockets = <Rocket>[
      Rocket(
        id: 'falcon9',
        manufacturer: 'SpaceX',
        name: 'Falcon 9',
        type: 'Heavy-Lift',
        description: 'Reusable two-stage rocket with Dragon spacecraft',
      ),
      Rocket(
        id: 'falconheavy',
        manufacturer: 'SpaceX',
        name: 'Falcon Heavy',
        type: 'Extra-Heavy',
        description: 'Full-sized launch vehicle for human spaceflight',
      ),
      Rocket(
        id: 'dragon2',
        manufacturer: 'SpaceX',
        name: 'Dragon 2',
        type: 'Spacecraft',
        description: 'Crew and cargo spacecraft for ISS',
      ),
      Rocket(
        id: 'starship',
        manufacturer: 'SpaceX',
        name: 'Starship',
        type: 'Super-Heavy',
        description: 'Fully reusable interplanetary spacecraft',
      ),
    ];

    // Add other providers' rockets
    rockets.add(Rocket(
      id: 'long_march_5',
      manufacturer: 'CNSA',
      name: 'Long March 5',
      type: 'Heavy',
      description: 'China's primary heavy-lift rocket',
    ));

    rockets.add(Rocket(
      id: 'gaganavyah',
      manufacturer: 'ISRO',
      name: 'Gaganyaan',
      type: 'Human-rated',
      description: 'ISRO's crew spacecraft',
    ));

    return rockets;
  }

  /// Fetch all providers
  Future<List<LaunchProvider>> fetchProviders() async {
    return <LaunchProvider>[
      LaunchProvider(
        id: 'spacex',
        name: 'SpaceX',
        abbreviation: 'SpaceX',
        country: 'United States',
        status: 'active',
        successRate: 0.95,
        launches: 150,
        failures: 7,
        description: 'American aerospace manufacturer of rockets, satellites, space transportation systems, and spacecraft',
      ),
      LaunchProvider(
        id: 'nasa',
        name: 'NASA',
        abbreviation: 'NASA',
        country: 'United States',
        status: 'active',
        successRate: 0.97,
        launches: 100,
        failures: 3,
        description: 'United States government agency for space and aeronautics research',
      ),
      LaunchProvider(
        id: 'cnsa',
        name: 'CNSA',
        abbreviation: 'CNSA',
        country: 'China',
        status: 'active',
        successRate: 0.91,
        launches: 180,
        failures: 17,
        description: 'China National Space Administration',
      ),
      LaunchProvider(
        id: 'esa',
        name: 'ESA',
        abbreviation: 'ESA',
        country: 'Europe',
        status: 'active',
        successRate: 0.92,
        launches: 80,
        failures: 8,
        description: 'European Space Agency',
      ),
      LaunchProvider(
        id: 'isro',
        name: 'ISRO',
        abbreviation: 'ISRO',
        country: 'India',
        status: 'active',
        successRate: 1.0,
        launches: 90,
        failures: 0,
        description: 'Indian Space Research Organisation',
      ),
      LaunchProvider(
        id: 'jaxa',
        name: 'JAXA',
        abbreviation: 'JAXA',
        country: 'Japan',
        status: 'active',
        successRate: 0.94,
        launches: 60,
        failures: 4,
        description: 'Japan Aerospace Exploration Agency',
      ),
      LaunchProvider(
        id: 'rocket_lab',
        name: 'Rocket Lab',
        abbreviation: 'RL',
        country: 'United States',
        status: 'active',
        successRate: 0.87,
        launches: 40,
        failures: 6,
        description: 'New space launch services provider',
      ),
      LaunchProvider(
        id: 'ariane',
        name: 'Arianespace',
        abbreviation: 'Arianespace',
        country: 'Europe',
        status: 'active',
        successRate: 0.90,
        launches: 200,
        failures: 20,
        description: 'European space transport services company',
      ),
      LaunchProvider(
        id: 'russian_cosmos',
        name: 'Roscosmos',
        abbreviation: 'Roscosmos',
        country: 'Russia',
        status: 'active',
        successRate: 0.89,
        launches: 250,
        failures: 28,
        description: 'Russian state space agency',
      ),
    ];
  }

  /// Fetch launch sites
  Future<List<LaunchSite>> fetchLaunchSites() async {
    return <LaunchSite>[
      LaunchSite(
        code: 'LC39A',
        name: 'Kennedy Space Center LC-39A',
        lat: 28.5729,
        lon: -80.6490,
        country: 'United States',
        area: 'Florida',
      ),
      LaunchSite(
        code: 'KSCJSLC-E',
        name: 'Kennedy Space Center LC-39B',
        lat: 28.5731,
        lon: -80.6350,
        country: 'United States',
        area: 'Florida',
      ),
      LaunchSite(
        code: 'VAFB-SLC-4E',
        name: 'Vandenberg SLC-4E',
        lat: 34.6320,
        lon: -120.6100,
        country: 'United States',
        area: 'California',
      ),
      LaunchSite(
        code: 'XICHANG',
        name: 'Xichang Satellite Launch Center',
        lat: 28.25,
        lon: 102.00,
        country: 'China',
        area: 'Sichuan',
      ),
      LaunchSite(
        code: 'TAISHAN',
        name: 'Taiyuan Satellite Launch Center',
        lat: 38.85,
        lon: 111.60,
        country: 'China',
        area: 'Shanxi',
      ),
      LaunchSite(
        code: 'JIUSHAN',
        name: 'Jiuquan Satellite Launch Center',
        lat: 40.95,
        lon: 100.29,
        country: 'China',
        area: 'Gansu',
      ),
      LaunchSite(
        code: 'WEISHAN',
        name: 'Wenchang Spacecraft Launch Site',
        lat: 19.61,
        lon: 110.95,
        country: 'China',
        area: 'Hainan',
      ),
      LaunchSite(
        code: 'PAMIRS_6',
        name: 'Baikonur Cosmodrome',
        lat: 45.9650,
        lon: 63.3050,
        country: 'Kazakhstan',
        area: 'Kazakhstan',
      ),
      LaunchSite(
        code: 'PLESS',
        name: 'Plesetsk Cosmodrome',
        lat: 62.9200,
        lon: 40.5600,
        country: 'Russia',
        area: 'Arkhangelsk',
      ),
      LaunchSite(
        code: 'GUAYANA',
        name: 'Guiana Space Center',
        lat: 5.1830,
        lon: -52.7780,
        country: 'French Guiana',
        area: 'South America',
      ),
      LaunchSite(
        code: 'SATISH',
        name: 'Satish Dhawan Space Centre',
        lat: 13.72,
        lon: 80.23,
        country: 'India',
        area: 'Andhra Pradesh',
      ),
      LaunchSite(
        code: 'NAGASHINO',
        name: 'Tanegashima Space Center',
        lat: 30.40,
        lon: 130.97,
        country: 'Japan',
        area: 'Kagoshima',
      ),
    ];
  }

  /// Fetch with fallback to other sources
  Future<List<Launch>> fetchLaunchesWithFallback({
    int limit = 50,
    int skip = 0,
    required DataSource primarySource,
  }) async {
    // Try primary source first
    try {
      final primaryLaunches = await _fetchFromSource(primarySource);
      if (primaryLaunches.isNotEmpty) return primaryLaunches;
    } catch (_) {
      // Continue to fallbacks
    }

    // Try secondary sources
    final secondaryLaunches = <Map<String, dynamic>>[];
    
    // Add more launches from secondary sources if needed
    return secondaryLaunches;
  }

  /// Fetch single launch with fallback
  Future<Launch?> fetchLaunchWithFallback({required String id}) async {
    // Try primary
    final primary = await _fetchFromSource(DataSource.spacex());
    if (primary.isNotEmpty) return primary.first;

    // Try secondary
    return null;
  }
}
