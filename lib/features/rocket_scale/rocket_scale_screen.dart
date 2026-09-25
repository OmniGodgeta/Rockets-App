import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/rocket_scale_data.dart';
import '../../utils/wikipedia_thumbnail.dart';

/// Rocket Size Comparison, drawn to a single shared scale so relative
/// heights are actually correct (the previous version scaled every item to
/// fill its own separate box, so a 1.7 m human and a 70 m Falcon 9 came out
/// nearly the same size on screen - the exact bug reported). A bottom slider
/// scrubs from the smallest (human) to the largest (Starship V3), revealing
/// everything up to that point side by side, matching the reference video's
/// "rocket size comparison" style: everything visible together, ordered
/// smallest to largest, with a real reference photo per rocket.
class RocketScaleScreen extends StatefulWidget {
  const RocketScaleScreen({super.key});

  @override
  State<RocketScaleScreen> createState() => _RocketScaleScreenState();
}

class _RocketScaleScreenState extends State<RocketScaleScreen> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = (rocketScaleData.length - 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final upToIndex = _sliderValue.round().clamp(0, rocketScaleData.length - 1);
    final visible = rocketScaleData.sublist(0, upToIndex + 1);
    // Shared scale factor: pixels per meter, based on the TALLEST item
    // currently revealed by the slider (not the whole dataset), so the bars
    // always use the full available height as you scrub further out.
    final tallest = visible.last.heightMeters;

    return Scaffold(
      appBar: AppBar(title: const Text('ROCKET SIZE COMPARISON')),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final drawHeight = constraints.maxHeight - 80;
                final scaleFactor = drawHeight / tallest;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: visible.length,
                  itemBuilder: (context, index) => _RocketBar(
                    rocket: visible[index],
                    scaleFactor: scaleFactor,
                    isSelected: index == upToIndex,
                  ),
                );
              },
            ),
          ),
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rocketScaleData[upToIndex].name,
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.accent,
                    inactiveTrackColor: AppTheme.surfaceBorder,
                    thumbColor: AppTheme.accent,
                    overlayColor: AppTheme.accent.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _sliderValue,
                    min: 0,
                    max: (rocketScaleData.length - 1).toDouble(),
                    divisions: rocketScaleData.length - 1,
                    onChanged: (value) => setState(() => _sliderValue = value),
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('HUMAN',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10)),
                    Text('STARSHIP V3',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RocketBar extends StatelessWidget {
  final RocketScale rocket;
  final double scaleFactor;
  final bool isSelected;

  const _RocketBar({
    required this.rocket,
    required this.scaleFactor,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final drawHeight = rocket.heightMeters * scaleFactor;
    final drawWidth = (rocket.diameterMeters * scaleFactor).clamp(18.0, 140.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          WikipediaThumbnail(wikipediaTitle: rocket.wikipediaTitle),
          const SizedBox(height: 6),
          SizedBox(
            width: drawWidth,
            height: drawHeight,
            child: CustomPaint(
              painter: _SilhouettePainter(
                color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
              ),
              size: Size(drawWidth, drawHeight),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(
              rocket.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${rocket.heightMeters.toStringAsFixed(1)} m',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  final Color color;

  _SilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double bottomY = size.height;
    const double topY = 0;
    final double halfWidth = size.width / 2;

    const double noseConeRatio = 0.15;
    final double noseHeight = size.height * noseConeRatio;
    final double bodyHeight = size.height - noseHeight;

    final Path path = Path();
    path.moveTo(centerX - halfWidth, bottomY);
    path.lineTo(centerX - halfWidth, bottomY - bodyHeight);
    path.quadraticBezierTo(
      centerX - (halfWidth * 0.3),
      topY + (noseHeight * 0.5),
      centerX,
      topY,
    );
    path.quadraticBezierTo(
      centerX + (halfWidth * 0.3),
      topY + (noseHeight * 0.5),
      centerX + halfWidth,
      bottomY - bodyHeight,
    );
    path.lineTo(centerX + halfWidth, bottomY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
