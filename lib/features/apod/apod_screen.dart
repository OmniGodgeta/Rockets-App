import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../data/gallery_repository.dart';

/// "Gallery" - renamed from "Astronomy Picture of the Day", which used to be
/// a single WebView loading NASA's own bare HTML page (plain white
/// background, one image, no history). Now a native, themed, infinite,
/// newest-first feed combining two NASA sources.
class ApodScreen extends StatefulWidget {
  const ApodScreen({super.key});

  @override
  State<ApodScreen> createState() => _ApodScreenState();
}

class _ApodScreenState extends State<ApodScreen> {
  final _repository = GalleryRepository();
  final _scrollController = ScrollController();
  final List<GalleryImage> _images = [];

  DateTime _apodCursor = DateTime.now();
  int _libraryPage = 1;
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore(initial: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _loadMore({bool initial = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repository.fetchApod(endDate: _apodCursor, days: 8),
        _repository.fetchImageLibrary(page: _libraryPage),
      ]);
      final combined = [...results[0], ...results[1]];
      combined.sort((a, b) => b.date.compareTo(a.date));
      if (mounted) {
        setState(() {
          _images.addAll(combined);
          _apodCursor = _apodCursor.subtract(const Duration(days: 8));
          _libraryPage += 1;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted && _images.isEmpty) {
        setState(() => _error = 'Could not load imagery: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _initialLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GALLERY')),
      body: _initialLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : _error != null && _images.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.textSecondary)),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _images.length + (_loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _images.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.accent),
                        ),
                      );
                    }
                    return _GalleryCard(image: _images[index]);
                  },
                ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final GalleryImage image;

  const _GalleryCard({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: CachedNetworkImage(
              imageUrl: image.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.broken_image, color: AppTheme.textSecondary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat.yMMMd().format(image.date)} · ${image.source}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
