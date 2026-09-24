import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/favorite_repository.dart';
import '../../data/launch_repository.dart';
import '../../data/satellite_repository.dart';
import '../../models/launch.dart';
import '../../models/satellite_model.dart';
import '../rockets/launch_detail_screen.dart';
import '../satellites/satellite_detail_sheet.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  final LaunchRepository _launchRepository = LaunchRepository();
  final SatelliteRepository _satelliteRepository = SatelliteRepository();

  late TabController _tabController;
  bool _isInitialized = false;
  bool _isLoadingLaunches = false;
  bool _isLoadingSatellites = false;

  List<Launch> _allLaunches = [];
  List<Satellite> _allSatellites = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initialize();
  }

  Future<void> _initialize() async {
    await _favoriteRepository.init();
    await _launchRepository.init();
    // Satellite repository doesn't have an init(), but we might need to fetch it
    setState(() => _isInitialized = true);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!_isInitialized) return;

    setState(() => _isLoadingLaunches = true);
    try {
      _allLaunches = await _launchRepository.fetchUpcoming(limit: 100);
    } catch (e) {
      debugPrint('Error loading launches: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLaunches = false);
    }

    setState(() => _isLoadingSatellites = true);
    try {
      _allSatellites = await _satelliteRepository.fetchActiveSatellites();
    } catch (e) {
      debugPrint('Error loading satellites: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSatellites = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAVORITES'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'SATELLITES'),
            Tab(text: 'LAUNCHES'),
          ],
        ),
      ),
      body: _isLoadingLaunches || _isLoadingSatellites
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSatelliteList(),
                _buildLaunchList(),
              ],
            ),
    );
  }

  Widget _buildSatelliteList() {
    final favoriteIds = _favoriteRepository.getFavoriteSatelliteIds();
    final favorites = _allSatellites.where((s) => favoriteIds.contains(s.noradId)).toList();

    if (favorites.isEmpty) {
      return const _EmptyState(message: 'No favorited satellites.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final s = favorites[index];
        return Card(
          color: AppTheme.surface,
          child: ListTile(
            title: Text(s.name, style: const TextStyle(color: AppTheme.textPrimary)),
            subtitle: Text('NORAD: ${s.noradId}', style: const TextStyle(color: AppTheme.textSecondary)),
            onTap: () async {
               showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (ctx) => SatelliteDetailSheet(
                  satellite: s,
                  userLat: 0.0,
                  userLon: 0.0,
                  userAltKm: 0.0,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLaunchList() {
    final favoriteIds = _favoriteRepository.getFavoriteLaunchIds();
    final favorites = _allLaunches.where((l) => favoriteIds.contains(l.id.toString())).toList();

    if (favorites.isEmpty) {
      return const _EmptyState(message: 'No favorited launches.');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final l = favorites[index];
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => LaunchDetailScreen(launch: l)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: ListTile(
              title: Text(l.name.toUpperCase(), style: const TextStyle(color: AppTheme.textPrimary)),
              subtitle: Text('${l.rocketName} - ${l.locationName}', style: const TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }
}
