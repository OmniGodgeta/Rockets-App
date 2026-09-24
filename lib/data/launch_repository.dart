import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/launch.dart';

/// Fetches upcoming launches from the Launch Library 2 public API
/// (https://thespacedevs.com/llapi) - no API key required.
class LaunchRepository {
  static const _baseUrl = 'https://ll.thespacedevs.com/2.2.0';

  Future<List<Launch>> fetchUpcoming({int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl/launch/upcoming/?limit=$limit');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Launch Library request failed: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];
    return results
        .map((json) => Launch.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
