import 'app_constants.dart';

// SpaceX API Service
class spacexApiService {
  // Get all launches
  static Future<Map<String, dynamic>> getLaunches() async {
    try {
      // Simulated data - replace with actual HTTP calls
      return {
        'launches': [
          {
            'id': '5f8a7b0d87051b8f4c8a01c9',
            'name': 'Starlink-26',
            'date_utc': '2025-01-01T00:00:00.000Z',
            'flight_number': 90,
            'rocket': '5f9d9bd3d1d4b327afa664a2',
            'success': true,
            'details': 'Starlink launch',
            'upcoming': false,
            'tbd': false,
          },
        ],
        'total': 1,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Get a single launch
  static Future<Map<String, dynamic>> getLaunch(String id) async {
    try {
      return {'id': id, 'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Get all rockets
  static Future<Map<String, dynamic>> getRockets() async {
    try {
      return {
        'rockets': [
          {
            'id': '5f9d9bd3d1d4b327afa664a2',
            'name': 'Falcon 9',
            'type': 'rocket',
            'active': true,
            'first_flight': '2010-06-04',
            'manufacturer': 'SpaceX',
          },
        ],
        'total': 1,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
