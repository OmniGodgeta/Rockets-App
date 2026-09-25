import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/theme.dart';
import '../../data/satellite_repository.dart';
import '../../models/satellite_model.dart';
import '../../utils/orbit_utils.dart';
import 'compass_screen.dart';

/// "ISS Live Now" - the current ISS position on a live map plus a real-time
/// next-pass estimate for the user's location, with a button into the
/// existing compass tracker. Replaces the old ISS Tracker, which just
/// embedded a generic third-party "satellitemap.space" WebView (showing all
/// satellites, not specifically the ISS, and with no location/compass
/// integration at all). Fully native - no WebView, no ads.
class IssLiveNowScreen extends StatefulWidget {
  const IssLiveNowScreen({super.key});

  @override
  State<IssLiveNowScreen> createState() => _IssLiveNowScreenState();
}

class _IssLiveNowScreenState extends State<IssLiveNowScreen> {
  final _repository = SatelliteRepository();
  final MapController _mapController = MapController();
  Timer? _refreshTimer;

  Satellite? _iss;
  Position? _userLocation;
  Map<String, double>? _issPosition;
  DateTime? _nextPass;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _updatePosition());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      _iss = await _repository.fetchIssSatellite();
      await _resolveUserLocation();
      _updatePosition();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load ISS data: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resolveUserLocation() async {
    try {
      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
      }
      if (status.isGranted) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        if (mounted) setState(() => _userLocation = position);
      }
    } catch (e) {
      debugPrint('IssLiveNowScreen: could not resolve user location: $e');
    }
  }

  void _updatePosition() {
    final iss = _iss;
    if (iss == null || !mounted) return;
    final pos = OrbitUtils.getSatellitePosition(iss, DateTime.now().toUtc());
    setState(() => _issPosition = pos);

    final userLoc = _userLocation;
    if (userLoc != null) {
      final nextPass = OrbitUtils.calculateNextPass(
        iss,
        userLoc.latitude,
        userLoc.longitude,
        userLoc.altitude / 1000,
      );
      if (mounted) setState(() => _nextPass = nextPass);
    }
  }

  String _formatNextPass() {
    final pass = _nextPass;
    if (pass == null)
      return _userLocation == null
          ? 'Enable location to see'
          : 'No pass in next 24h';
    final diff = pass.difference(DateTime.now().toUtc());
    if (diff.inMinutes <= 0) return 'Overhead now!';
    if (diff.inHours > 0) return 'In ${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'In ${diff.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISS LIVE NOW')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : _error != null
              ? _ErrorState(
                  message: _error!,
                  onRetry: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _initialize();
                  })
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final pos = _issPosition;
    final center =
        pos != null ? LatLng(pos['lat']!, pos['lon']!) : const LatLng(0, 0);

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: pos == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accent))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 2.5,
                    minZoom: 1,
                    maxZoom: 8,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rockets.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 44,
                          height: 44,
                          child: const Icon(Icons.satellite_alt,
                              color: Colors.redAccent, size: 36),
                        ),
                      ],
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors')
                      ],
                    ),
                  ],
                ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            color: AppTheme.background,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'LATITUDE',
                        value: pos != null
                            ? '${pos['lat']!.toStringAsFixed(2)}°'
                            : '—',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'LONGITUDE',
                        value: pos != null
                            ? '${pos['lon']!.toStringAsFixed(2)}°'
                            : '—',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'ALTITUDE',
                        value: pos != null
                            ? '${pos['alt']!.toStringAsFixed(0)} km'
                            : '—',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                          label: 'NEXT PASS OVER YOU',
                          value: _formatNextPass()),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _iss == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CompassScreen(satellite: _iss!),
                            ),
                          ),
                  icon: const Icon(Icons.explore),
                  label: const Text('TRACK WITH COMPASS'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: AppTheme.textSecondary, size: 40),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('RETRY')),
        ],
      ),
    );
  }
}
