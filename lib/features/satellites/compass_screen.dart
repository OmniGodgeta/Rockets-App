import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  double? _targetElevation;
  double? _devicePitch;
  Position? _userLocation;
  bool _isInitializing = true;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  Timer? _lookAngleTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _accelSubscription?.cancel();
    _lookAngleTimer?.cancel();
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

      // 2. Start Compass Stream (horizontal heading)
      _compassSubscription = FlutterCompass.events?.listen((event) {
        setState(() {
          _heading = event.heading;
        });
      });

      // 3. Start Accelerometer Stream (device pitch, for the vertical axis
      // the compass never had before)
      _accelSubscription =
          accelerometerEventStream().listen(_onAccelerometerEvent);

      // 4. Satellite look angle (azimuth + elevation) barely changes over a
      // couple of seconds, so it's recomputed on a timer rather than on
      // every sensor tick.
      _updateLookAngle();
      _lookAngleTimer = Timer.periodic(
          const Duration(seconds: 2), (_) => _updateLookAngle());
    } catch (e) {
      debugPrint('Error initializing compass screen: $e');
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  // Exponential smoothing so the pitch reading isn't jittery from raw
  // accelerometer noise.
  double? _smoothedPitch;

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Device held vertically, portrait, pointed at the target (typical
    // "AR camera" grip): y runs along the phone's long axis (up/down when
    // held upright), z is out of the screen. Tilting the top of the phone
    // up (aiming higher) reduces z and increases -y, hence atan2(-y, z).
    // Needs on-device confirmation - accelerometer axis conventions can
    // differ enough between phones that the sign may need flipping.
    final rawPitch = math.atan2(-event.y, event.z) * (180 / math.pi);
    final smoothed = _smoothedPitch == null
        ? rawPitch
        : _smoothedPitch! + 0.15 * (rawPitch - _smoothedPitch!);
    _smoothedPitch = smoothed;
    setState(() => _devicePitch = smoothed);
  }

  void _updateLookAngle() {
    final pos = _userLocation;
    if (pos == null) return;
    final result = OrbitUtils.getLookAngle(
      widget.satellite,
      pos.latitude,
      pos.longitude,
      pos.altitude / 1000,
      DateTime.now().toUtc(),
    );
    if (result == null) return;
    setState(() {
      _targetAzimuth = result['azimuth'];
      _targetElevation = result['elevation'];
    });
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
    final double? elevation = _targetElevation;
    final double? pitch = _devicePitch;
    // The direction the user should turn to face the satellite is (azimuth - heading)
    final double relativeBearing = (azimuth - heading + 360) % 360;
    final bool azimuthAligned = relativeBearing < 5 || relativeBearing > 355;
    final double? pitchDelta =
        (elevation != null && pitch != null) ? elevation - pitch : null;
    final bool elevationAligned =
        pitchDelta == null ? true : pitchDelta.abs() < 5;

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

        // Vertical elevation gauge - the compass's missing "up/down" axis.
        // Shows where the satellite sits above/below the horizon (elevation)
        // against the phone's own current tilt (pitch); the marker lands in
        // the middle only once the phone is pointed at the right height.
        if (pitchDelta != null)
          Positioned(
            right: 24,
            child: _ElevationGauge(pitchDelta: pitchDelta),
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
              if (elevation != null) ...[
                const SizedBox(height: 8),
                Text(
                  'ELEVATION: ${elevation.toStringAsFixed(1)}°'
                  '${elevation < 0 ? ' (below horizon)' : ''}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                azimuthAligned && elevationAligned
                    ? 'POINT AT SATELLITE!'
                    : !azimuthAligned
                        ? 'TURN TO FACE'
                        : (pitchDelta ?? 0) > 0
                            ? 'TILT UP'
                            : 'TILT DOWN',
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
        color: AppTheme.surface.withValues(alpha: 0.5),
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

/// A vertical gauge: the marker sits in the middle band once the phone's
/// current tilt (pitch) matches the satellite's elevation above the
/// horizon. [pitchDelta] is elevation-minus-pitch in degrees, clamped to
/// +/-45deg of travel on the gauge.
class _ElevationGauge extends StatelessWidget {
  final double pitchDelta;

  const _ElevationGauge({required this.pitchDelta});

  @override
  Widget build(BuildContext context) {
    const trackHeight = 200.0;
    const maxDelta = 45.0;
    final clamped = pitchDelta.clamp(-maxDelta, maxDelta);
    // Positive delta (target above current pitch) moves the marker up.
    final offsetY = -(clamped / maxDelta) * (trackHeight / 2);
    final aligned = pitchDelta.abs() < 5;

    return SizedBox(
      height: trackHeight,
      width: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 4,
            height: trackHeight,
            decoration: BoxDecoration(
              color: AppTheme.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Icon(Icons.remove, color: AppTheme.textSecondary, size: 20),
          Transform.translate(
            offset: Offset(0, offsetY),
            child: Icon(
              Icons.arrow_left,
              color: aligned ? Colors.greenAccent : Colors.redAccent,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
