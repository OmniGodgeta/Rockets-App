import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

import '../app/theme.dart';

/// Fetches a real reference photo via Wikipedia's page-summary API (a live
/// call, not a hardcoded image URL) and shows it as a small round badge.
/// Shared by RocketScaleScreen and ScaleScreen so both real-imagery features
/// use the same fetch/cache/error-handling logic.
class WikipediaThumbnail extends StatefulWidget {
  final String wikipediaTitle;
  final double size;

  const WikipediaThumbnail({
    super.key,
    required this.wikipediaTitle,
    this.size = 44,
  });

  @override
  State<WikipediaThumbnail> createState() => _WikipediaThumbnailState();
}

class _WikipediaThumbnailState extends State<WikipediaThumbnail> {
  static final Map<String, String?> _cache = {};
  String? _imageUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant WikipediaThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wikipediaTitle != widget.wikipediaTitle) {
      _loading = true;
      _imageUrl = null;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    if (_cache.containsKey(widget.wikipediaTitle)) {
      if (mounted) {
        setState(() {
          _imageUrl = _cache[widget.wikipediaTitle];
          _loading = false;
        });
      }
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
            'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(widget.wikipediaTitle)}'),
        headers: {'User-Agent': 'RocketsApp/1.0'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final thumbnail = body['thumbnail'] as Map<String, dynamic>?;
        final url = thumbnail?['source'] as String?;
        _cache[widget.wikipediaTitle] = url;
        if (mounted) setState(() => _imageUrl = url);
      }
    } catch (_) {
      // No photo available - callers still render fine without one.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.surfaceBorder),
        color: AppTheme.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: _loading
          ? Center(
              child: SizedBox(
                width: widget.size * 0.35,
                height: widget.size * 0.35,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : _imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: _imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                      Icons.image_not_supported,
                      size: widget.size * 0.45),
                )
              : Icon(Icons.image_not_supported,
                  size: widget.size * 0.45, color: AppTheme.textSecondary),
    );
  }
}
