import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// A single image in the Gallery, normalized from whichever NASA source it
/// came from (APOD or the NASA Image and Video Library) so the UI doesn't
/// need to know which API produced it.
class GalleryImage {
  final String title;
  final DateTime date;
  final String imageUrl;
  final String? explanation;
  final String source;

  const GalleryImage({
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.explanation,
    required this.source,
  });
}

/// Fetches real space imagery from two NASA sources - not just the single
/// APOD-of-the-day page the old WebView showed - merged into one
/// newest-first feed:
///  - Astronomy Picture of the Day (api.nasa.gov/planetary/apod)
///  - NASA Image and Video Library (images-api.nasa.gov, no key required)
///
/// Uses NASA's public DEMO_KEY, which is rate-limited (30 req/hour/IP) but
/// requires no signup - fine for personal use. If that limit becomes a
/// problem, request a free key at https://api.nasa.gov and set it here.
class GalleryRepository {
  static const _apodKey = 'DEMO_KEY';
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  /// Fetches [days] days of APOD entries ending on [endDate] (inclusive),
  /// newest first. Skips non-image entries (APOD occasionally posts a video).
  Future<List<GalleryImage>> fetchApod({
    required DateTime endDate,
    int days = 10,
  }) async {
    final startDate = endDate.subtract(Duration(days: days - 1));
    final uri = Uri.parse(
      'https://api.nasa.gov/planetary/apod'
      '?api_key=$_apodKey'
      '&start_date=${_dateFormat.format(startDate)}'
      '&end_date=${_dateFormat.format(endDate)}',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('APOD HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as List<dynamic>;
    final images = body
        .cast<Map<String, dynamic>>()
        .where((e) => e['media_type'] == 'image')
        .map((e) => GalleryImage(
              title: e['title'] as String? ?? 'Untitled',
              date: DateTime.parse(e['date'] as String),
              imageUrl: (e['hdurl'] as String?) ?? (e['url'] as String? ?? ''),
              explanation: e['explanation'] as String?,
              source: 'NASA APOD',
            ))
        .where((e) => e.imageUrl.isNotEmpty)
        .toList();
    images.sort((a, b) => b.date.compareTo(a.date));
    return images;
  }

  /// Fetches a page of recent imagery from the NASA Image and Video Library,
  /// searching for major mission/observatory names so results stay relevant
  /// rather than pulling in unrelated archive photos.
  Future<List<GalleryImage>> fetchImageLibrary({int page = 1}) async {
    final uri = Uri.parse(
      'https://images-api.nasa.gov/search'
      '?q=hubble%20webb%20telescope%20nebula%20galaxy'
      '&media_type=image'
      '&page=$page',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('NASA Image Library HTTP ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (body['collection']['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final images = <GalleryImage>[];
    for (final item in items) {
      final data =
          (item['data'] as List<dynamic>).cast<Map<String, dynamic>>();
      if (data.isEmpty) continue;
      final meta = data.first;
      final links =
          (item['links'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
      final imageUrl = links
          ?.map((l) => l['href'] as String?)
          .firstWhere((h) => h != null, orElse: () => null);
      if (imageUrl == null) continue;
      final dateCreated = meta['date_created'] as String?;
      images.add(GalleryImage(
        title: meta['title'] as String? ?? 'Untitled',
        date:
            dateCreated != null ? DateTime.parse(dateCreated) : DateTime.now(),
        imageUrl: imageUrl,
        explanation: meta['description'] as String?,
        source: 'NASA Image Library',
      ));
    }
    images.sort((a, b) => b.date.compareTo(a.date));
    return images;
  }
}
