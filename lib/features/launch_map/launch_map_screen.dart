import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../app/theme.dart';
import '../../data/launch_repository.dart';
import '../../models/launch.dart';
import '../rockets/launch_detail_screen.dart';

/// Every upcoming launch on a world map, one marker per pad. Uses the launch
/// list the Rockets tab already caches, so it costs no extra API calls.
class LaunchMapScreen extends StatefulWidget {
  const LaunchMapScreen({super.key});

  @override
  State<LaunchMapScreen> createState() => _LaunchMapScreenState();
}

class _Pad {
  _Pad(this.point, this.name, this.location);
  final LatLng point;
  final String name;
  final String location;
  final launches = <Launch>[];
}

class _LaunchMapScreenState extends State<LaunchMapScreen> {
  final _repo = LaunchRepository();
  late final Future<List<Launch>> _launches = _load();
  bool _next30 = true;

  Future<List<Launch>> _load() async {
    await _repo.init();
    return _repo.fetchUpcoming();
  }

  List<_Pad> _pads(List<Launch> all) {
    final now = DateTime.now();
    final pads = <String, _Pad>{};
    for (final l in all) {
      final lat = l.padLatitude, lon = l.padLongitude;
      if (lat == null || lon == null) continue;
      if (l.net.isBefore(now.subtract(const Duration(hours: 6)))) continue;
      if (_next30 && l.net.isAfter(now.add(const Duration(days: 30)))) continue;
      final key = '${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';
      pads
          .putIfAbsent(key, () => _Pad(LatLng(lat, lon), l.padName, l.locationName))
          .launches
          .add(l);
    }
    for (final p in pads.values) {
      p.launches.sort((a, b) => a.net.compareTo(b.net));
    }
    return pads.values.toList();
  }

  void _showPad(_Pad pad) {
    final fmt = DateFormat('EEE, MMM d · HH:mm');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              ListTile(
                title: Text(pad.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700)),
                subtitle: Text(pad.location,
                    style: const TextStyle(color: AppTheme.textSecondary)),
              ),
              for (final l in pad.launches)
                ListTile(
                  leading: const Icon(Icons.rocket_launch_outlined,
                      color: AppTheme.accent),
                  title: Text(l.name,
                      style: const TextStyle(color: AppTheme.textPrimary)),
                  subtitle: Text(fmt.format(l.net.toLocal()),
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => LaunchDetailScreen(launch: l)));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LAUNCH MAP'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _next30 = !_next30),
            child: Text(_next30 ? 'NEXT 30 DAYS' : 'ALL UPCOMING',
                style: const TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
      body: FutureBuilder<List<Launch>>(
        future: _launches,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (snap.hasError) {
            return const Center(
              child: Text("Couldn't load launches.",
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          final pads = _pads(snap.data ?? const []);
          final soon = DateTime.now().add(const Duration(days: 7));
          final total = pads.fold<int>(0, (n, p) => n + p.launches.length);
          return Stack(
            children: [
              FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(20, 0),
                  initialZoom: 1.6,
                  minZoom: 1,
                  maxZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.rockets.app',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final p in pads)
                        Marker(
                          point: p.point,
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showPad(p),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.launches.first.net.isBefore(soon)
                                    ? AppTheme.accent
                                    : AppTheme.surface,
                                border: Border.all(
                                    color: AppTheme.textPrimary, width: 2),
                              ),
                              child: Text('${p.launches.length}',
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: AppTheme.surface.withValues(alpha: 0.9),
                  child: Text(
                    '$total launches from ${pads.length} pads · blue = '
                    'launching within 7 days · tap a pad',
                    style: const TextStyle(color: AppTheme.textSecondary),
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
