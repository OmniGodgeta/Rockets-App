import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../utils/moon_phase.dart';

/// Tonight's Moon: phase, how much is lit, and the next new and full moons.
/// Computed on the phone (utils/moon_phase.dart), so it works offline.
class MoonScreen extends StatelessWidget {
  const MoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final p = MoonPhase.at(now);
    final nextFull = MoonPhase.next(180, now).toLocal();
    final nextNew = MoonPhase.next(0, now).toLocal();
    final upcoming = [
      (label: 'Full Moon', at: nextFull),
      (label: 'New Moon', at: nextNew),
    ]..sort((a, b) => a.at.compareTo(b.at));
    final fmt = DateFormat('EEE, MMM d · HH:mm');

    String inDays(DateTime t) {
      final d = t.difference(now).inHours / 24;
      if (d < 1) return 'in ${t.difference(now).inHours} h';
      return 'in ${d.round()} days';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('THE MOON')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(painter: _MoonPainter(p)),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(p.name.toUpperCase(),
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${(p.illumination * 100).round()}% lit · '
              '${p.waxing ? 'waxing' : 'waning'} · '
              'day ${p.ageDays.floor() + 1} of ${MoonPhase.synodicMonth.toStringAsFixed(1)}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ),
          const SizedBox(height: 28),
          for (final u in upcoming)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CustomPaint(
                      painter: _MoonPainter(MoonPhase.at(u.at)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next ${u.label}',
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600)),
                        Text(fmt.format(u.at),
                            style: const TextStyle(
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Text(inDays(u.at),
                      style: const TextStyle(color: AppTheme.accent)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'A new moon means dark skies: the best nights for stars, the Milky '
            'Way and spotting the ISS. Around full moon, the Moon itself is '
            'the show.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The Moon disc with its lit part, as seen from the northern hemisphere
/// (waxing = lit on the right). The terminator is an ellipse whose half
/// width is |cos(elongation)| of the radius.
class _MoonPainter extends CustomPainter {
  _MoonPainter(this.p);
  final MoonPhase p;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final dark = Paint()..color = const Color(0xFF1C222B);
    final lit = Paint()..color = const Color(0xFFE9E4D4);
    canvas.drawCircle(c, r, dark);

    final k = math.cos(p.elongation * math.pi / 180); // 1 new, -1 full
    final litRight = p.waxing;
    final path = Path()
      // the lit half-disc (right half when waxing)
      ..addArc(Rect.fromCircle(center: c, radius: r),
          litRight ? -math.pi / 2 : math.pi / 2, math.pi);
    final term = Rect.fromCenter(center: c, width: 2 * r * k.abs(), height: 2 * r);
    final ellipse = Path()..addOval(term);
    final shape = k > 0
        // crescent: half-disc minus the terminator ellipse
        ? Path.combine(PathOperation.difference, path, ellipse)
        // gibbous: half-disc plus the terminator ellipse
        : Path.combine(PathOperation.union, path, ellipse);
    canvas.drawPath(shape, lit);
    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0x33FFFFFF));
  }

  @override
  bool shouldRepaint(_MoonPainter old) => old.p.elongation != p.elongation;
}
