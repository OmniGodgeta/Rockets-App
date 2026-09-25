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
  String _selectedProvider = 'All';

  @override
  void initState() {
    super.initState();
    // Assign _launchesFuture synchronously here (to the Future this async
    // call returns immediately, not its eventual result) so it's never
    // unassigned even for one frame. The previous version called an async
    // fire-and-forget function from initState and only assigned
    // _launchesFuture inside its later setState - the very first build()
    // could run before that ever happened, throwing a real
    // LateInitializationError (reproduced via `flutter test`, not just a
    // theoretical race).
    _launchesFuture = _initializeAndFetch();
  }

  Future<List<Launch>> _initializeAndFetch() async {
    await _repository.init();
    await _favoriteRepository.init();
    if (mounted) {
      setState(() {
        _favoritesInitialized = true;
      });
    }
    return _repository.fetchUpcoming();
  }

  Future<void> _refresh() async {
    // useCache: false - pull-to-refresh must force a real network fetch.
    // Without this it was silently re-reading the same cached data and
    // doing nothing visible to the user.
    setState(() {
      _launchesFuture = _repository.fetchUpcoming(useCache: false);
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
          final allLaunches = snapshot.data ?? [];
          if (allLaunches.isEmpty) {
            return const Center(
              child: Text(
                'No upcoming launches found.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          final providers = <String>{'All'};
          for (final l in allLaunches) {
            providers.add(l.providerName);
          }
          final sortedProviders = providers.toList()
            ..sort(
                (a, b) => a == 'All' ? -1 : (b == 'All' ? 1 : a.compareTo(b)));
          final effectiveProvider =
              providers.contains(_selectedProvider) ? _selectedProvider : 'All';

          final launches = effectiveProvider == 'All'
              ? allLaunches
              : allLaunches
                  .where((l) => l.providerName == effectiveProvider)
                  .toList();

          return Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: sortedProviders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final provider = sortedProviders[index];
                    final selected = provider == effectiveProvider;
                    return ChoiceChip(
                      label:
                          Text(provider, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedProvider = provider),
                      backgroundColor: AppTheme.surface,
                      selectedColor: AppTheme.accent,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppTheme.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.normal,
                      ),
                      side: const BorderSide(color: AppTheme.surfaceBorder),
                    );
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.accent,
                  backgroundColor: AppTheme.surface,
                  onRefresh: _refresh,
                  child: launches.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'No launches from this provider right now.',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: launches.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) =>
                              _LaunchCard(launch: launches[index]),
                        ),
                ),
              ),
            ],
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
    final isLive = launch.isHappeningNow;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LaunchDetailScreen(launch: launch)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(
              color: isLive ? Colors.redAccent : AppTheme.surfaceBorder,
              width: isLive ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLive)
              Container(
                width: double.infinity,
                color: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Center(
                  child: Text(
                    'HAPPENING NOW',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (launch.imageUrl != null)
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: CachedNetworkImage(
                      imageUrl: launch.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.surfaceBorder,
                        child: const Icon(Icons.rocket_launch,
                            color: AppTheme.textSecondary, size: 32),
                      ),
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
                          style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${launch.rocketName} - ${launch.locationName}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (launch.webcastUrl != null) ...[
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Icon(Icons.live_tv,
                                  size: 14, color: Colors.redAccent),
                              SizedBox(width: 4),
                              Text('LIVESTREAM',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
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
          const Text('Could not load launches.',
              style: TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('$error',
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('RETRY')),
        ],
      ),
    );
  }
}
