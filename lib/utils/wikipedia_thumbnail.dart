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

  /// true (default): a small round badge at [size]x[size], used for the
  /// Scale of the Universe items. false: fills whatever box the parent
  /// gives it, undecorated - used by Rocket Scales, where the photo itself
  /// needs to sit inside an accurately-scaled height/width box rather than
  /// a fixed-size badge.
  final bool circular;
  final BoxFit fit;

  const WikipediaThumbnail({
    super.key,
    required this.wikipediaTitle,
    this.size = 44,
    this.circular = true,
    this.fit = BoxFit.cover,
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
    // Captured so a slow, out-of-order response for a title we've since
    // moved on from (e.g. the user dragged the slider past several items
    // before this request returned) can't overwrite the current one - this
    // was the actual cause of items showing another item's photo.
    final requestedTitle = widget.wikipediaTitle;

    if (_cache.containsKey(requestedTitle)) {
      if (mounted && widget.wikipediaTitle == requestedTitle) {
        setState(() {
          _imageUrl = _cache[requestedTitle];
          _loading = false;
        });
      }
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
            'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(requestedTitle)}'),
        headers: {'User-Agent': 'RocketsApp/1.0'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final thumbnail = body['thumbnail'] as Map<String, dynamic>?;
        final url = thumbnail?['source'] as String?;
        _cache[requestedTitle] = url;
        if (mounted && widget.wikipediaTitle == requestedTitle) {
          setState(() => _imageUrl = url);
        }
      }
    } catch (_) {
      // No photo available - callers still render fine without one.
    } finally {
      if (mounted && widget.wikipediaTitle == requestedTitle) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _content(double iconSize) {
    if (_loading) {
      return Center(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        fit: widget.fit,
        errorWidget: (context, url, error) =>
            Icon(Icons.image_not_supported, size: iconSize),
      );
    }
    return Icon(Icons.image_not_supported,
        size: iconSize, color: AppTheme.textSecondary);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.circular) {
      return _content(widget.size * 0.45);
    }
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.surfaceBorder),
        color: AppTheme.surface,
      ),
      clipBehavior: Clip.antiAlias,
      child: _content(widget.size * 0.35),
    );
  }
}
