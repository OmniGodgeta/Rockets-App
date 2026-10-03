import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/theme.dart';
import '../../data/iss_notification_service.dart';
import '../../data/satellite_repository.dart';
import '../../data/settings_repository.dart';
import '../../models/satellite_model.dart';
import '../../utils/external_apps.dart';
import '../../utils/orbit_utils.dart';
import '../../utils/wikipedia_thumbnail.dart';
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
  // The ISS never goes past ~52 deg N/S, so this frames every orbit fully.
  static final _worldFit = CameraFit.bounds(
    bounds: LatLngBounds(const LatLng(-62, -180), const LatLng(68, 180)),
  );

  final _repository = SatelliteRepository();
  final MapController _mapController = MapController();
  Timer? _refreshTimer;

  Satellite? _iss;
  Position? _userLocation;
  Map<String, double>? _issPosition;
  DateTime? _nextPass;
  IssPass? _nextVisiblePass;
  bool _locationFailed = false;
  bool _alertsOn = false;
  bool _alertsBusy = false;
  final _settings = SettingsRepository();
  Timer? _passTimer;
  String? _error;
  bool _loading = true;
  List<LatLng> _trackFuture = [];
  // Off by default: the default view is the whole world (below), where
  // following would just slide the map sideways. The locate button turns
  // it on and zooms in.
  bool _following = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _settings.init().then((_) {
      if (mounted) setState(() => _alertsOn = _settings.issPassAlertsEnabled);
    });
    // Pass predictions only change slowly; recomputing them every 5 s with
    // the marker wasted battery. Every 5 min is plenty.
    _passTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => _computePasses());
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _updatePosition());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _passTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      _iss = await _repository.fetchIssSatellite();
      _updatePosition();
      // Not awaited: the map and stats only need the ISS. Location just adds
      // the next-pass time, and a GPS fix can take ages (or never come
      // indoors / on an emulator), which used to keep the spinner up forever.
      unawaited(_resolveUserLocation());
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
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 10)),
          );
        } catch (e) {
          // No fresh fix (indoors, GPS off): the last known position is
          // easily good enough for pass predictions.
          position = await Geolocator.getLastKnownPosition();
          if (position == null) rethrow;
        }
        if (mounted) setState(() => _userLocation = position);
        _computePasses();
        return;
      }
    } catch (e) {
      debugPrint('IssLiveNowScreen: could not resolve user location: $e');
    }
    if (mounted) setState(() => _locationFailed = true);
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
  }

  void _computePasses() {
    final iss = _iss;
    final loc = _userLocation;
    if (iss == null || loc == null || !mounted) return;
    final altKm = loc.altitude / 1000;
    setState(() {
      _nextPass =
          OrbitUtils.calculateNextPass(iss, loc.latitude, loc.longitude, altKm);
      _nextVisiblePass = OrbitUtils.calculateNextVisiblePass(
          iss, loc.latitude, loc.longitude, altKm,
          range: const Duration(days: 14));
    });
  }

  Future<void> _toggleAlerts() async {
    final on = !_alertsOn;
    setState(() {
      _alertsOn = on;
      _alertsBusy = true;
    });
    await _settings.setIssPassAlertsEnabled(on);
    await IssNotificationService().refreshSchedule();
    if (!mounted) return;
    setState(() => _alertsBusy = false);
    final when = IssNotificationService.scheduledPassStart;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(!on
          ? 'ISS alerts off'
          : when != null
              ? "You'll be alerted 5 min before the ISS is visible (${_formatWhen(when)})"
              : "Alerts on. No visible pass in the next 14 days yet; we'll check again each time the app opens."),
    ));
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

  String _formatNextVisible() {
    if (_userLocation == null) {
      return _locationFailed
          ? 'Location unavailable'
          : 'Finding your location…';
    }
    final pass = _nextVisiblePass;
    if (pass == null) return 'None in the next 14 days';
    return _formatWhen(pass.start);
  }

  String? _visibleDetail() {
    final pass = _nextVisiblePass;
    if (pass == null) return null;
    final minutes = (pass.duration.inSeconds / 60).ceil();
    return 'Up to ${pass.maxElevationDeg.round()}° high · about $minutes min';
  }

  String? _aboveHorizonDetail() {
    final pass = _nextPass;
    if (pass == null) return null;
    final diff = pass.difference(DateTime.now().toUtc());
    if (diff.inMinutes <= 0) {
      return 'Above your horizon now (not necessarily visible)';
    }
    final h = diff.inHours, m = diff.inMinutes % 60;
    return 'Next above the horizon: in ${h > 0 ? '${h}h ' : ''}${m}m (daylight passes can\'t be seen)';
  }

  static String _formatWhen(DateTime t) {
    final l = t.toLocal();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDiff = DateTime(l.year, l.month, l.day).difference(today).inDays;
    final day = dayDiff == 0
        ? 'Today'
        : dayDiff == 1
            ? 'Tomorrow'
            : '${days[l.weekday - 1]} ${l.day} ${months[l.month - 1]}';
    final hh = l.hour.toString().padLeft(2, '0'),
        mm = l.minute.toString().padLeft(2, '0');
    return '$day, $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISS LIVE NOW'),
        actions: [
          // Hands off to the dedicated "ISS Live Now" app (live HD Earth
          // feed, 3D tracker) when installed, else its Play Store page.
          IconButton(
            tooltip: 'Open the ISS Live Now app',
            icon: const Icon(Icons.open_in_new),
            onPressed: () async {
              if (!await ExternalApps.open(ExternalApps.issLiveNow)) {
                await ExternalApps.openStore(ExternalApps.issLiveNow.last);
              }
            },
          ),
        ],
      ),
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
                        // Whole world by default. Zoomed in, a ground track
                        // is locally almost straight, so it read as "straight
                        // red lines, not an orbit". Only the full-world view
                        // shows the orbit's real S-shaped wave.
                        initialCameraFit: _worldFit,
                        // The world view is wider than tall, so the map shows
                        // past the poles; keep that dark, not default grey.
                        backgroundColor: AppTheme.background,
                        minZoom: 0,
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
                                color: Colors.redAccent.withValues(alpha: 0.85),
                                strokeWidth: 2.5,
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
                    // Says what the line is: users read a bare red line as
                    // "all the previous and future orbits".
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.background.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                width: 18, height: 3, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            const Text('Path for the next 90 min',
                                style: TextStyle(
                                    color: AppTheme.textPrimary, fontSize: 11)),
                          ],
                        ),
                      ),
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
                              (_mapController.camera.zoom - 1).clamp(0, 8),
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
                            icon: Icons.public,
                            onPressed: () {
                              setState(() => _following = false);
                              _mapController.fitCamera(_worldFit);
                            },
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
            // Same visual language as Scale of the Universe: circular
            // Wikipedia badge, headline name, accent readout pill on a
            // bordered dark card, secondary caption, then bordered cards.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Same stack as Scale of the Universe: circular photo,
                  // wide-tracked headline, then the accent readout pill.
                  const Center(
                    child: WikipediaThumbnail(
                        wikipediaTitle: 'International_Space_Station',
                        size: 72),
                  ),
                  const SizedBox(height: 12),
                  Text('International Space Station',
                      textAlign: TextAlign.center,
                      style: AppTheme.headline.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  const Text('Live position · updates every 5 s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        const Text('NEXT VISIBLE PASS',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(_formatNextVisible(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        if (_visibleDetail() != null) ...[
                          const SizedBox(height: 2),
                          Text(_visibleDetail()!,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary, fontSize: 12)),
                        ],
                        if (_aboveHorizonDetail() != null) ...[
                          const SizedBox(height: 4),
                          Text(_aboveHorizonDetail()!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 10)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: 'LONGITUDE',
                          value: pos != null
                              ? '${pos['lon']!.toStringAsFixed(2)}°'
                              : '—',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: 'ALTITUDE',
                          value: pos != null
                              ? '${pos['alt']!.toStringAsFixed(0)} km'
                              : '—',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _alertsBusy ? null : _toggleAlerts,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: BorderSide(
                          color: _alertsOn
                              ? AppTheme.accent
                              : AppTheme.surfaceBorder),
                    ),
                    icon: Icon(_alertsOn
                        ? Icons.notifications_active
                        : Icons.notifications_none),
                    label: Text(_alertsBusy
                        ? 'FINDING THE NEXT VISIBLE PASS…'
                        : _alertsOn
                            ? 'ALERTS ON · TAP TO TURN OFF'
                            : 'NOTIFY ME WHEN VISIBLE'),
                  ),
                  const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
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
      color: AppTheme.surface.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.surfaceBorder),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.textPrimary, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
