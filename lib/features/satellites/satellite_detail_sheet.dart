import 'package:flutter/material.dart';
import '../../models/satellite_model.dart';
import '../../utils/orbit_utils.dart';
import '../../app/theme.dart';
import '../../data/favorite_repository.dart';

class SatelliteDetailSheet extends StatefulWidget {
  final Satellite satellite;
  final double userLat;
  final double userLon;
  final double userAltKm;

  const SatelliteDetailSheet({
    super.key,
    required this.satellite,
    required this.userLat,
    required this.userLon,
    required this.userAltKm,
  });

  @override
  State<SatelliteDetailSheet> createState() => _SatelliteDetailSheetState();
}

class _SatelliteDetailSheetState extends State<SatelliteDetailSheet> {
  late final FavoriteRepository _favoriteRepository;
  bool _favoritesReady = false;

  @override
  void initState() {
    super.initState();
    _favoriteRepository = FavoriteRepository();
    _favoriteRepository.init().then((_) {
      if (mounted) setState(() => _favoritesReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isFavorite = _favoritesReady &&
        _favoriteRepository.isSatelliteFavorite(widget.satellite.noradId);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        border: null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.satellite.name.toUpperCase(),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'NORAD ID: ${widget.satellite.noradId}',
            style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const Divider(height: 32, color: AppTheme.surfaceBorder),
          _buildInfoRow(context, 'Current Position', _getCurrentPosition()),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Next Pass', _getNextPassText()),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: !_favoritesReady
                  ? null
                  : () async {
                      await _favoriteRepository.toggleSatelliteFavorite(widget.satellite.noradId);
                      if (mounted) {
                        setState(() {});
                      }
                    },
              child: Text(isFavorite ? 'REMOVE FROM FAVORITES' : 'ADD TO FAVORITES'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
        Text(value, style: textTheme.bodyMedium),
      ],
    );
  }

  String _getCurrentPosition() {
    final now = DateTime.now().toUtc();
    final pos = OrbitUtils.getSatellitePosition(widget.satellite, now);
    if (pos['lat'] == 0.0 && pos['lon'] == 0.0 && pos['alt'] == 0.0) return 'Unknown';
    
    return '${pos['lat']!.toStringAsFixed(2)}°, ${pos['lon']!.toStringAsFixed(2)}° @ ${pos['alt']!.toStringAsFixed(1)}km';
  }

  String _getNextPassText() {
    final nextPass = OrbitUtils.calculateNextPass(
      widget.satellite, 
      widget.userLat, 
      widget.userLon, 
      widget.userAltKm
    );

    if (nextPass == null) return 'No upcoming passes today';

    final diff = nextPass.difference(DateTime.now().toUtc());
    final minutes = diff.inMinutes;
    final hours = diff.inHours;

    if (hours > 0) {
      return 'In $hours ${minutes % 60}m';
    } else if (minutes > 0) {
      return 'In ${minutes}m';
    } else {
      return 'Passing now!';
    }
  }
}
