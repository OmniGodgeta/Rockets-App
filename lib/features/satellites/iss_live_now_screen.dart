import 'dart:async';
import 'dart:math' as math;
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
  List<LatLng> _trackFuture = [];
  bool _following = true;
  bool _mapReady = false;

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
    final now = DateTime.now().toUtc();
    final pos = OrbitUtils.getSatellitePosition(iss, now);
    setState(() => _issPosition = pos);
    _computeTrack(iss, now);

    // Real ISS trackers keep the satellite centered as it moves - a map
    // with only an `initialCenter` never re-centers on its own once built,
    // so without this the marker would drift toward (and past) the edge of
    // the viewport within a few minutes. Guarded by _mapReady: calling
    // MapController.move()/.camera before FlutterMap has rendered at least
    // once throws (this fires once immediately from _initialize(), before
    // the map widget exists yet).
    if (_following && _mapReady) {
      _mapController.move(
        LatLng(pos['lat']!, pos['lon']!),
        _mapController.camera.zoom,
      );
    }

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

  /// Ground track: current position forward through one full orbit only
  /// (~93 min for the ISS at its current altitude - no past trace). Showing
  /// both a 45-min past AND 45-min future trace (as this screen used to)
  /// covers nearly two full orbits combined once Earth's rotation between
  /// them is accounted for, which is a lot more line than "where is it
  /// headed" needs and reads as clutter. Longitude wraps at +/-180deg, so a
  /// single Polyline would draw a bogus line clear across the map at each
  /// wrap - split into segments there instead (see _splitAtAntimeridian).
  void _computeTrack(Satellite iss, DateTime now) {
    const sampleEvery = Duration(seconds: 30);
    const orbitalPeriod = Duration(minutes: 93);

    final points = <LatLng>[];
    final steps = orbitalPeriod.inSeconds ~/ sampleEvery.inSeconds;
    for (var i = 0; i <= steps; i++) {
      final p = OrbitUtils.getSatellitePosition(iss, now.add(sampleEvery * i));
      points.add(LatLng(p['lat']!, p['lon']!));
    }

    if (mounted) setState(() => _trackFuture = points);
  }

  /// Splits a track into segments wherever consecutive points cross the
  /// antimeridian, so flutter_map never draws a straight line all the way
  /// across the map at a longitude wrap.
  static List<List<LatLng>> _splitAtAntimeridian(List<LatLng> points) {
    if (points.isEmpty) return [];
    final segments = <List<LatLng>>[];
    var current = <LatLng>[points.first];
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      if ((curr.longitude - prev.longitude).abs() > 180) {
        segments.add(current);
        current = [];
      }
      current.add(curr);
    }
    segments.add(current);
    return segments;
  }

  /// The ground-track radius (in meters) of the region from which the ISS
  /// is above the horizon right now, from real satellite-footprint
  /// geometry: for a satellite at altitude [altKm] above a sphere of mean
  /// Earth radius R, the angular radius of the footprint is
  /// acos(R / (R + altitude)), and the ground radius is R times that angle
  /// (in radians).
  static double _footprintRadiusMeters(double altKm) {
    const earthRadiusKm = 6371.0;
    final centralAngle = math.acos(earthRadiusKm / (earthRadiusKm + altKm));
    return earthRadiusKm * centralAngle * 1000;
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
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 2.5,
                        minZoom: 1,
                        maxZoom: 8,
                        onMapReady: () => setState(() => _mapReady = true),
                        // A manual drag/pinch (hasGesture) means the person
                        // wants to look somewhere else - stop auto-following
                        // so the next 5s position update doesn't immediately
                        // snap the view back to the ISS.
                        onPositionChanged: (camera, hasGesture) {
                          if (hasGesture && _following) {
                            setState(() => _following = false);
                          }
                        },
                      ),
                      children: [
                        // Real satellite photography of the Earth instead
                        // of a vector line-art map, per the operator's ask
                        // for a "realistic" map here.
                        TileLayer(
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.rockets.app',
                        ),
                        // Visibility footprint: the ground region from which
                        // the ISS is above the horizon right now - the
                        // signature visual of every real ISS tracker, and
                        // something this screen never had at all before.
                        // Radius from real satellite-footprint geometry:
                        // groundRadius = earthRadius * acos(earthRadius /
                        // (earthRadius + altitude)).
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: center,
                              radius: _footprintRadiusMeters(pos['alt']!),
                              useRadiusInMeter: true,
                              color: Colors.redAccent.withValues(alpha: 0.08),
                              borderColor:
                                  Colors.redAccent.withValues(alpha: 0.4),
                              borderStrokeWidth: 1.5,
                            ),
                          ],
                        ),
                        // Current position onward through one orbit only -
                        // no past trace. One solid style throughout.
                        PolylineLayer(
                          polylines: [
                            for (final segment
                                in _splitAtAntimeridian(_trackFuture))
                              Polyline(
                                points: segment,
                                color: Colors.redAccent.withValues(alpha: 0.7),
                                strokeWidth: 2,
                              ),
                          ],
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
                            TextSourceAttribution('Esri World Imagery'),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Column(
                        children: [
                          _MapToolButton(
                            icon: Icons.add,
                            onPressed: () => _mapController.move(
                              _mapController.camera.center,
                              (_mapController.camera.zoom + 1).clamp(1, 8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _MapToolButton(
                            icon: Icons.remove,
                            onPressed: () => _mapController.move(
                              _mapController.camera.center,
                              (_mapController.camera.zoom - 1).clamp(1, 8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _MapToolButton(
                            icon: Icons.my_location,
                            onPressed: () {
                              setState(() => _following = true);
                              _mapController.move(center, 2.5);
                            },
                          ),
                          const SizedBox(height: 6),
                          _MapToolButton(
                            icon: _following
                                ? Icons.gps_fixed
                                : Icons.gps_not_fixed,
                            onPressed: () =>
                                setState(() => _following = !_following),
                          ),
                        ],
                      ),
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

/// A small round zoom/recenter control overlaid on the map - the "tools"
/// this screen was missing entirely.
class _MapToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapToolButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textPrimary, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
