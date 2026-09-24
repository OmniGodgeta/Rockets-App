import 'package:flutter/material.dart';
import '../../data/rocket_scale_data.dart';

class RocketScaleScreen extends StatelessWidget {
  const RocketScaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rocket Size Comparison'),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          itemCount: rocketScaleData.length + 1, // +1 for the human reference
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _HumanReferenceItem();
            } else {
              final rocket = rocketScaleData[index - 1];
              return _RocketComparisonItem(rocket: rocket);
            }
          },
        ),
      ),
    );
  }
}

class _HumanReferenceItem extends StatelessWidget {
  const _HumanReferenceItem();

  @override
  Widget build(BuildContext context) {
    // Fixed width to prevent jitter in horizontal ListView
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AspectRatio(
            aspectRatio: 1 / 3,
            child: CustomPaint(
              painter: _SilhouettePainter(
                heightMeters: averageHumanHeight,
                diameterMeters: 0.5, // Simplified human width
                color: Colors.grey,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Human', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text('${averageHumanHeight.toStringAsFixed(1)} m'),
        ],
      ),
    );
  }
}

class _RocketComparisonItem extends StatelessWidget {
  final RocketScale rocket;

  const _RocketComparisonItem({required this.rocket});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1 / 5, // Tall aspect ratio for rockets
              child: CustomPaint(
                painter: _SilhouettePainter(
                  heightMeters: rocket.heightMeters,
                  diameterMeters: rocket.diameterMeters,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            rocket.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text('${rocket.heightMeters.toStringAsFixed(1)} m'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  final double heightMeters;
  final double diameterMeters;
  final Color color;

  _SilhouettePainter({
    required this.heightMeters,
    required this.diameterMeters,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // scaleFactor = pixels / meters
    final double scaleFactor = size.height / heightMeters;
    
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double drawHeight = heightMeters * scaleFactor;
    final double drawWidth = diameterMeters * scaleFactor;

    final Path path = Path();
    
    final double centerX = size.width / 2;
    final double bottomY = size.height;
    final double topY = 0;

    final double halfWidth = drawWidth / 2;
    
    const double noseConeRatio = 0.15; // Top 15% is the nose cone
    final double noseHeight = drawHeight * noseConeRatio;
    final double bodyHeight = drawHeight - noseHeight;
    
    // Base coordinates relative to center and bottom
    path.moveTo(centerX - halfWidth, bottomY); 
    
    // Draw vertical side (body)
    path.lineTo(centerX - halfWidth, bottomY - bodyHeight);
    
    // Nose Cone: Quadratic Bezier from corner to tip
    path.quadraticBezierTo(
      centerX - (halfWidth * 0.3), // Control point x
      topY + (noseHeight * 0.5),   // Control point y
      centerX,                     // End point x: the absolute tip
      topY,                        // End point y: the absolute tip
    );

    // Symmetric down the other side
    path.quadraticBezierTo(
      centerX + (halfWidth * 0.3), // Control point x
      topY + (noseHeight * 0.5),   // Control point y
      centerX + halfWidth,         // End point x: other shoulder
      bottomY - bodyHeight,        // End point y: other shoulder
    );
    
    // Bottom side
    path.lineTo(centerX + halfWidth, bottomY);
    
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter oldDelegate) {
    return oldDelegate.heightMeters != heightMeters ||
           oldDelegate.diameterMeters != diameterMeters ||
           oldDelegate.color != color;
  }
}
