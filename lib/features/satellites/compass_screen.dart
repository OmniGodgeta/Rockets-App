import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/theme.dart';
import '../../models/satellite_model.dart';
import '../../utils/orbit_utils.dart';

/// A screen that provides a visual compass overlay showing the user's heading 
/// and the azimuthal bearing (direction) towards a specific satellite.
class CompassScreen extends StatefulWidget {
  final Satellite satellite;

  const CompassScreen({super.key, required this.satellite});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double? _heading;
  double? _targetAzimuth;
  Position? _userLocation;
  bool _isInitializing = true;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      // 1. Get Location
      var status = await Permission.location.status;
      if (status.isDenied) {
        status = await Permission.location.request();
      }

      if (!status.isGranted) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      setState(() {
        _userLocation = position;
      });

      // 2. Start Compass Stream
      _compassSubscription = FlutterCompass.events?.listen((event) {
        setState(() {
          _heading = event.heading;
        });
        _updateTargetAzimuth();
      });

      // 3. Initial calculation for azimuth
      _updateTargetAzimuth();

    } catch (e) {
      debugPrint('Error initializing compass screen: $e');
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  void _updateTargetAzimuth() async {
    final pos = _userLocation;
    final heading = _heading;
    final sat = widget.satellite;

    if (pos == null || heading == null) return;

    try {
      // Get current satellite position via SGP4 propagation
      final now = DateTime.now().toUtc();

      final satPosMap = OrbitUtils.getSatellitePosition(sat, now);
      final satLat = satPosMap['lat']!;
      final satLon = satPosMap['lon']!;

      final azimuth = OrbitUtils.calculateAzimuth(
        pos.latitude,
        pos.longitude,
        satLat,
        satLon,
      );

      setState(() {
        _targetAzimuth = azimuth;
      });
    } catch (e) {
      debugPrint('Error calculating azimuth: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.satellite.name, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: _buildCompassView(),
      ),
    );
  }

  Widget _buildCompassView() {
    if (_isInitializing) {
      return const CircularProgressIndicator(color: AppTheme.accent);
    }

    if (_userLocation == null || _heading == null || _targetAzimuth == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sensors_off, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          const Text('Waiting for sensor data...', style: TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _initialize, child: const Text('RETRY')),
        ],
      );
    }

    final double heading = _heading!;
    final double azimuth = _targetAzimuth!;
    // The direction the user should turn to face the satellite is (azimuth - heading)
    final double relativeBearing = (azimuth - heading + 360) % 360;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Compass Ring
        Transform.rotate(
          angle: -heading * (math.pi / 180),
          child: _buildCompassRing(),
        ),
        
        // Target Needle/Arrow
        Transform.rotate(
          angle: relativeBearing * (math.pi / 180),
          child: const Icon(
            Icons.navigation,
            color: Colors.redAccent,
            size: 48,
          ),
        ),

        // UI Info Overlay
        Positioned(
          bottom: 40,
          child: Column(
            children: [
              Text(
                'AZIMUTH: ${azimuth.toStringAsFixed(1)}°',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'HEADING: ${heading.toStringAsFixed(1)}°',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Text(
                relativeBearing < 5 || relativeBearing > 355 
                    ? 'POINT AT SATELLITE!' 
                    : 'TURN TO FACE',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompassRing() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.surfaceBorder, width: 2),
        color: AppTheme.surface.withOpacity(0.5),
      ),
      child: Stack(
        children: [
          // Simplified Compass Markings (N, E, S, W)
          _buildMarking(0, 'N'),
          _buildMarking(90, 'E'),
          _buildMarking(180, 'S'),
          _buildMarking(270, 'W'),
        ],
      ),
    );
  }

  Widget _buildMarking(double angle, String label) {
    return Transform.translate(
      offset: const Offset(0, -130), // Move to edge of ring
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(width: 2, height: 10, color: AppTheme.accent),
          ],
        ),
      ),
    );
  }
}
