import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../app/theme.dart';
import 'satellite_detail_sheet.dart';
import '../../data/satellite_repository.dart';
import '../../models/satellite_model.dart';
import '../../utils/orbit_utils.dart';

/// \"Satellites\" tab: a live Starlink-map-style 3D view of every satellite in
/// orbit (https://satellitemap.space).
class SatellitesScreen extends StatefulWidget {
  const SatellitesScreen({super.key});

  @override
  State<SatellitesScreen> createState() => _SatellitesScreenState();
}

class _SatellitesScreenState extends State<SatellitesScreen> {
  late final WebViewController _controller;
  final SatelliteRepository _repository = SatelliteRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Satellite> _searchResults = [];
  bool _isSearching = false;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _currentHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..loadRequest(Uri.parse('https://satellitemap.space/'));
    _requestLocationPermission();
    _startCompassTracking();
  }

  void _startCompassTracking() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        setState(() {
          _currentHeading = event.heading!;
        });
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
        setState(() => _isLoadingLocation = false);
      } else {
        throw Exception('Location permissions denied');
      }
    } catch (e) {
      debugPrint('Location error: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final all = await _repository.fetchActiveSatellites();
      final matches = all.where((s) => 
        s.name.toLowerCase().contains(query.toLowerCase()) || 
        s.noradId == query).toList();
      setState(() {
        _searchResults = matches;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() => _isSearching = false);
    }
  }

  void _showSatelliteDetails(Satellite satellite) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Allow sheet to use its own styling
      builder: (ctx) => SatelliteDetailSheet(
        satellite: satellite,
        userLat: _currentPosition?.latitude ?? 0.0,
        userLon: _currentPosition?.longitude ?? 0.0,
        userAltKm: 0.0, // We avoid complex height calc for now to remain stable
      ),
    );
  }

  void _handleCompassMode() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location to use Compass Mode')),
      );
      return;
    }

    if (_searchResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search for a satellite first!')),
      );
      return;
    }

    // For simplicity in this pass, we guide the user to select from search results
    // or show direction to the FIRST searched result.
    final target = _searchResults.first;
    final posMap = OrbitUtils.getSatellitePosition(target, DateTime.now().toUtc());
    
    if (posMap['lat'] == 0.0) return;

    final azimuth = OrbitUtils.calculateAzimuth(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      posMap['lat']!,
      posMap['lon']!,
    );

    final diff = (azimuth - _currentHeading + 360) % 360;
    final visualDiff = diff > 180 ? diff - 180 : diff;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${target.name} Direction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Target Azimuth: ${azimuth.toStringAsFixed(1)}°'),
            Text('Your Heading: ${_currentHeading.toStringAsFixed(1)}°'),
            const SizedBox(height: 20),
            Text('Turn ${visualDiff < 90 ? 'LEFT' : 'RIGHT'} by ${visualDiff.toStringAsFixed(1)}°'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SATELLITES'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search satellite name...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _isSearching 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : null,
                filled: true,
                fillColor: AppTheme.surface,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: AppTheme.surfaceBorder),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_searchResults.isNotEmpty)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final s = _searchResults[index];
                  return ListTile(
                    title: Text(s.name, style: const TextStyle(color: AppTheme.textPrimary)),
                    subtitle: Text('NORAD: ${s.noradId}', style: const TextStyle(color: AppTheme.textSecondary)),
                    onTap: () {
                      setState(() {
                        _searchResults = [];
                        _searchController.clear();
                      });
                      _showSatelliteDetails(s);
                    },
                  );
                },
              ),
            ),
          if (_isLoadingLocation)
             const Center(child: CircularProgressIndicator(color: AppTheme.accent)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.surface,
        onPressed: _handleCompassMode,
        child: const Icon(Icons.explore, color: AppTheme.accent),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _compassSubscription?.cancel();
    super.dispose();
  }
}
