import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String? _radarTileUrlTemplate;
  bool _loadingLocation = true;
  String? _error;

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
      final past = radar['past'] as List<dynamic>;
      if (past.isEmpty) throw Exception('No radar frames available');
      final latest = past.last as Map<String, dynamic>;
      final path = latest['path'] as String;
      if (mounted) {
        setState(() {
          // {z}/{x}/{y} are filled in by flutter_map; 256 = tile size,
          // "2" = universal blue-green-red color scheme, "1_1" = smooth +
          // show underlying snow.
          _radarTileUrlTemplate = '$host$path/256/{z}/{x}/{y}/2/1_1.png';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load radar data: $e');
    }
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
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                  TextSourceAttribution('OpenStreetMap contributors'),
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
          if (_error != null)
            Positioned(
              bottom: 16,
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
