import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/satellite_repository.dart';
import '../../models/satellite_model.dart';
import '../../features/satellites/satellite_detail_sheet.dart';
import '../../app/theme.dart';

class ISSTrackerScreen extends StatefulWidget {
  const ISSTrackerScreen({super.key});

  @override
  State<ISSTrackerScreen> createState() => _ISSTrackerScreenState();
}

class _ISSTrackerScreenState extends State<ISSTrackerScreen> {
  static const String issNoradId = '25544';
  final SatelliteRepository _repository = SatelliteRepository();
  
  Satellite? _iss;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchISS();
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
      }
    } catch (_) {
      // Location is a nice-to-have for accurate next-pass timing; fall back
      // to no position (SatelliteDetailSheet handles null lat/lon) rather
      // than blocking the ISS position/favorite view on it.
    }
  }

  Future<void> _fetchISS() async {
    try {
      await _fetchLocation();
      final satellites = await _repository.fetchActiveSatellites();
      // Find the ISS in the fetched list. 
      // The repository extracts noradId from line 2 which is substring(2, 7).
      final found = satellites.firstWhere(
        (s) => s.noradId == issNoradId,
        orElse: () => Satellite(
          name: '',
          noradId: 'unknown',
          tleLine1: '',
          tleLine2: '',
        ),
      );

      if (found.noradId == 'unknown') {
        throw Exception('ISS (NORAD ID $issNoradId) not found in satellite catalog.');
      }

      setState(() {
        _iss = found;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISS Tracker', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: AppTheme.background,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Container(
        color: AppTheme.background,
        child: Center(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: AppTheme.textPrimary);
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchISS,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final satellite = _iss;
    if (satellite == null) {
      return const Text('No ISS data available', style: TextStyle(color: AppTheme.textSecondary));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SatelliteDetailSheet(
              satellite: satellite,
              userLat: _currentPosition?.latitude ?? 0.0,
              userLon: _currentPosition?.longitude ?? 0.0,
              userAltKm: 0.0,
            ),
          ],
        ),
      ),
    );
  }
}
