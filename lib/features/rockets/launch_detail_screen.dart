import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../../data/favorite_repository.dart';
import '../../models/launch.dart';
import '../../features/radar/radar_screen.dart';
import '../../utils/rocket_countdown.dart';

class LaunchDetailScreen extends StatefulWidget {
  const LaunchDetailScreen({super.key, required this.launch});

  final Launch launch;

  @override
  State<LaunchDetailScreen> createState() => _LaunchDetailScreenState();
}

class _LaunchDetailScreenState extends State<LaunchDetailScreen> {
  late final FavoriteRepository _favoriteRepository;
  bool _favoritesReady = false;

  Launch get launch => widget.launch;

  @override
  void initState() {
    super.initState();
    _favoriteRepository = FavoriteRepository();
    _favoriteRepository.init().then((_) {
      if (mounted) setState(() => _favoritesReady = true);
    });
  }

  Future<void> _openWebcast() async {
    final url = launch.webcastUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openRadar() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RadarScreen(
          lat: launch.padLatitude,
          lon: launch.padLongitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, y - HH:mm');
    final isFavorite = _favoritesReady && _favoriteRepository.isLaunchFavorite(launch.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(launch.name.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: !_favoritesReady
                ? null
                : () async {
                    await _favoriteRepository.toggleLaunchFavorite(launch.id);
                    if (mounted) setState(() {});
                  },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (launch.imageUrl != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: launch.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const ColoredBox(color: AppTheme.surfaceBorder),
              ),
            ),
          const SizedBox(height: 16),
          Text(launch.name.toUpperCase(), style: AppTheme.headline.copyWith(fontSize: 20)),
          const SizedBox(height: 8),
          Text(dateFormat.format(launch.net.toLocal()), style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          RocketCountdown(net: launch.net),
          const SizedBox(height: 16),
          _InfoRow(label: 'STATUS', value: launch.statusName),
          _InfoRow(label: 'ROCKET', value: launch.rocketName),
          _InfoRow(label: 'PAD', value: launch.padName),
          _InfoRow(label: 'LOCATION', value: launch.locationName),
          if (launch.missionDescription != null && launch.missionDescription!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('MISSION', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            const SizedBox(height: 6),
            Text(launch.missionDescription!, style: const TextStyle(color: AppTheme.textPrimary, height: 1.4)),
          ],
          if (launch.webcastUrl != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _openWebcast,
              icon: const Icon(Icons.live_tv),
              label: const Text('WATCH LIVESTREAM'),
            ),
          ],
          if (launch.padLatitude != null && launch.padLongitude != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openRadar,
              icon: const Icon(Icons.radar),
              label: const Text('WEATHER RADAR AT LAUNCH SITE'),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary))),
        ],
      ),
    );
  }
}

