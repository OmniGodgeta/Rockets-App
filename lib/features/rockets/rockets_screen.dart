import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../data/favorite_repository.dart';
import '../../data/launch_repository.dart';
import '../../models/launch.dart';
import 'launch_detail_screen.dart';
import '../favorites/favorites_screen.dart';
import '../../utils/rocket_countdown.dart';

/// "Rockets" tab: scrollable feed of upcoming launches worldwide, similar in 
/// spirit to SpaceLaunchNow. Tap a launch for detail + livestream link.
class RocketsScreen extends StatefulWidget {
  const RocketsScreen({super.key, this.onMenuPressed});

  final VoidCallback? onMenuPressed;

  @override
  State<RocketsScreen> createState() => _RocketsScreenState();
}

class _RocketsScreenState extends State<RocketsScreen> {
  final _repository = LaunchRepository();
  final _favoriteRepository = FavoriteRepository();
  late Future<List<Launch>> _launchesFuture;
  bool _favoritesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
  }

  Future<void> _initializeRepositories() async {
    await _repository.init();
    await _favoriteRepository.init();
    if (mounted) {
      setState(() {
        _favoritesInitialized = true;
        _launchesFuture = _repository.fetchUpcoming();
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _launchesFuture = _repository.fetchUpcoming();
    });
    await _launchesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROCKETS'),
        leading: widget.onMenuPressed != null
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuPressed,
              )
            : null,
        actions: [
          if (_favoritesInitialized)
            IconButton(
              icon: const Icon(Icons.star),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),
        ],
      ),
      body: FutureBuilder<List<Launch>>(
        future: _launchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            );
          }
          if (snapshot.hasError) {
            return _ErrorState(onRetry: _refresh, error: snapshot.error);
          }
          final launches = snapshot.data ?? [];
          if (launches.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming launches found.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: launches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _LaunchCard(launch: launches[index]),
            ),
          );
        },
      ),
    );
  }
}

class _LaunchCard extends StatelessWidget {
  const _LaunchCard({required this.launch});

  final Launch launch;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y - HH:mm');
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LaunchDetailScreen(launch: launch)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (launch.imageUrl != null)
              SizedBox(
                width: 96,
                height: 96,
                child: CachedNetworkImage(
                  imageUrl: launch.imageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const ColoredBox(color: AppTheme.surfaceBorder),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      launch.name.toUpperCase(),
                      style: AppTheme.headline.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dateFormat.format(launch.net.toLocal()),
                      style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${launch.rocketName} - ${launch.locationName}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (launch.webcastUrl != null) ...[
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.live_tv, size: 14, color: Colors.redAccent),
                          SizedBox(width: 4),
                          Text('LIVESTREAM', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            RocketCountdown(net: launch.net),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, required this.error});

  final VoidCallback onRetry;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: AppTheme.textSecondary, size: 40),
          const SizedBox(height: 12),
          const Text('Could not load launches.', style: TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('$error', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('RETRY')),
        ],
      ),
    );
  }
}
