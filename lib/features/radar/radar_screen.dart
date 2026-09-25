import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';

/// Weather radar, rebuilt as a native OpenStreetMap + RainViewer map instead
/// of embedding zoom.earth's WebView. That page injects an app-install nag
/// modal *and* a Google AdSense banner (both confirmed by inspecting its
/// actual markup) - CSS/JS injection could only ever chase specific class
/// names, not guarantee zero ads from a third party's page. RainViewer's
/// public radar tile API (https://www.rainviewer.com/api.html) requires no
/// key and serves no ads at all, so this is a real fix rather than another
/// round of whack-a-mole.
class RadarScreen extends StatefulWidget {
  final double? lat;
  final double? lon;

  const RadarScreen({super.key, this.lat, this.lon});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(28.5, -80.6); // Cape Canaveral fallback
  bool _loadingLocation = true;
  String? _error;

  /// Every scrubbable radar frame (past + forecast), oldest first, so the
  /// slider reads left = past, right = future like other weather-radar apps.
  List<_RadarFrame> _frames = [];
  String? _radarHost;
  int _frameIndex = 0;
  Timer? _animationTimer;

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.lat != null && widget.lon != null) {
      _center = LatLng(widget.lat!, widget.lon!);
      _loadingLocation = false;
    } else {
      _resolveUserLocation();
    }
    _loadRadarFrame();
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
        if (mounted) {
          setState(() {
            _center = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_center, 7);
        }
      }
    } catch (e) {
      debugPrint(
          'RadarScreen: could not resolve user location, using fallback: $e');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _loadRadarFrame() async {
    try {
      final response = await http.get(
          Uri.parse('https://api.rainviewer.com/public/weather-maps.json'));
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final host = body['host'] as String;
      final radar = body['radar'] as Map<String, dynamic>;
      final past =
          (radar['past'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final nowcast = (radar['nowcast'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      if (past.isEmpty) throw Exception('No radar frames available');

      final frames = [
        for (final f in past)
          _RadarFrame(
            time: DateTime.fromMillisecondsSinceEpoch(
                (f['time'] as num).toInt() * 1000,
                isUtc: true),
            path: f['path'] as String,
            isForecast: false,
          ),
        for (final f in nowcast)
          _RadarFrame(
            time: DateTime.fromMillisecondsSinceEpoch(
                (f['time'] as num).toInt() * 1000,
                isUtc: true),
            path: f['path'] as String,
            isForecast: true,
          ),
      ];

      if (mounted) {
        setState(() {
          _radarHost = host;
          _frames = frames;
          // Start on the most recent *past* frame ("now"), not frame 0.
          _frameIndex = past.length - 1;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load radar data: $e');
    }
  }

  String? get _radarTileUrlTemplate {
    if (_radarHost == null || _frames.isEmpty) return null;
    final frame = _frames[_frameIndex.clamp(0, _frames.length - 1)];
    // {z}/{x}/{y} are filled in by flutter_map; 256 = tile size, "2" =
    // universal blue-green-red color scheme, "1_1" = smooth + show
    // underlying snow.
    return '$_radarHost${frame.path}/256/{z}/{x}/{y}/2/1_1.png';
  }

  String _formatFrameLabel(_RadarFrame frame) {
    final diff = frame.time.difference(DateTime.now().toUtc());
    final minutes = diff.inMinutes;
    if (minutes.abs() < 2) return 'NOW';
    final hours = minutes.abs() ~/ 60;
    final rem = minutes.abs() % 60;
    final magnitude = hours > 0 ? '${hours}h ${rem}m' : '${minutes.abs()}m';
    return minutes < 0 ? '-$magnitude' : '+$magnitude';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WEATHER RADAR')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 6,
              minZoom: 2,
              maxZoom: 12,
            ),
            children: [
              // Esri World Imagery: real satellite photography instead of a
              // vector line-art map, so this reads as an actual globe. Free,
              // no API key, no attribution nag beyond the required credit.
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.rockets.app',
              ),
              if (_radarTileUrlTemplate != null)
                TileLayer(
                  urlTemplate: _radarTileUrlTemplate,
                  userAgentPackageName: 'com.rockets.app',
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _center,
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.location_pin,
                        color: Colors.redAccent, size: 36),
                  ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('Esri World Imagery'),
                  TextSourceAttribution('RainViewer'),
                ],
              ),
            ],
          ),
          if (_loadingLocation || _radarTileUrlTemplate == null)
            const Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.accent),
              ),
            ),
          if (_frames.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatFrameLabel(_frames[_frameIndex]),
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _animationTimer == null
                            ? Icons.play_arrow
                            : Icons.pause,
                        color: AppTheme.accent,
                      ),
                      onPressed: () {
                        if (_animationTimer == null) {
                          _animationTimer = Timer.periodic(
                            const Duration(milliseconds: 400),
                            (_) {
                              setState(() {
                                if (_frameIndex < _frames.length - 1) {
                                  _frameIndex++;
                                } else {
                                  _frameIndex = 0;
                                }
                              });
                            },
                          );
                        } else {
                          setState(() {
                            _animationTimer?.cancel();
                            _animationTimer = null;
                          });
                        }
                      },
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.accent,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: AppTheme.accent,
                        overlayColor: AppTheme.accent.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _frameIndex.toDouble(),
                        min: 0,
                        max: (_frames.length - 1).toDouble(),
                        divisions: _frames.length > 1 ? _frames.length - 1 : 1,
                        onChanged: (value) {
                          setState(() {
                            _frameIndex = value.round();
                            _animationTimer?.cancel();
                          });
                        },
                      ),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PAST',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 10)),
                        Text('FORECAST',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text(
                          'MORE LAYERS (WIND, TEMP) ON WINDY.COM',
                          style: TextStyle(fontSize: 10),
                        ),
                        onPressed: () async {
                          final lat = _center.latitude.toStringAsFixed(4);
                          final lon = _center.longitude.toStringAsFixed(4);
                          final url =
                              Uri.parse('https://www.windy.com/?$lat,$lon,7');
                          final opened = await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                          if (opened || !context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Could not open Windy.com')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Positioned(
              bottom: _frames.isNotEmpty ? 100 : 16,
              left: 16,
              right: 16,
              child: Material(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_error!,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RadarFrame {
  final DateTime time;
  final String path;
  final bool isForecast;

  const _RadarFrame({
    required this.time,
    required this.path,
    required this.isForecast,
  });
}
