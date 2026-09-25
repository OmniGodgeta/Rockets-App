import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Live countdown to a launch's `net` time.
///
/// Two layouts:
/// - `compact: true` - a single-line pill ("5d 04h 12m 09s") sized to its own
///   content. Used in list rows sitting next to an `Expanded` sibling.
/// - `compact: false` (default) - the larger 4-box DAYS/HRS/MIN/SEC display,
///   used on the full-width detail screen.
///
/// Both variants explicitly use `MainAxisSize.min` on their Row. Without that,
/// a Row defaults to `MainAxisSize.max`; as a non-flex child sitting next to
/// an `Expanded` in a parent Row (the list card), it would then claim the
/// entire row's width for itself before the Expanded gets a share, squeezing
/// the Expanded column down to near-zero width - which forces its Text
/// children to wrap one character per line (reproduced on-device: this is
/// what actually caused the vertical "S/e/p/2/5/.../2/0/2/6" wall of text).
class RocketCountdown extends StatefulWidget {
  const RocketCountdown({super.key, required this.net, this.compact = false});

  final DateTime net;
  final bool compact;

  @override
  State<RocketCountdown> createState() => _RocketCountdownState();
}

class _RocketCountdownState extends State<RocketCountdown> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _isLaunched = false;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => _calculateRemaining());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemaining() {
    if (!mounted) return;
    final diff = widget.net.difference(DateTime.now());
    setState(() {
      if (diff.isNegative) {
        _isLaunched = true;
        _remaining = Duration.zero;
      } else {
        _isLaunched = false;
        _remaining = diff;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLaunched) {
      return widget.compact
          ? const Text(
              'LAUNCHED',
              style: TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            )
          : Center(
              child: Text(
                'LAUNCHED',
                style: AppTheme.headline.copyWith(
                  color: AppTheme.accent,
                  letterSpacing: 4,
                ),
              ),
            );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (widget.compact) {
      final label = days > 0
          ? '${days}d ${hours.toString().padLeft(2, '0')}h '
              '${minutes.toString().padLeft(2, '0')}m'
          : '${hours.toString().padLeft(2, '0')}h '
              '${minutes.toString().padLeft(2, '0')}m '
              '${seconds.toString().padLeft(2, '0')}s';
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimeUnit(value: days, label: 'DAYS'),
        const SizedBox(width: 14),
        const Text(':',
            style: TextStyle(fontSize: 26, color: AppTheme.textSecondary)),
        const SizedBox(width: 14),
        _TimeUnit(value: hours, label: 'HRS'),
        const SizedBox(width: 14),
        const Text(':',
            style: TextStyle(fontSize: 26, color: AppTheme.textSecondary)),
        const SizedBox(width: 14),
        _TimeUnit(value: minutes, label: 'MIN'),
        const SizedBox(width: 14),
        const Text(':',
            style: TextStyle(fontSize: 26, color: AppTheme.textSecondary)),
        const SizedBox(width: 14),
        _TimeUnit(value: seconds, label: 'SEC'),
      ],
    );
  }
}

class _TimeUnit extends StatelessWidget {
  const _TimeUnit({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: AppTheme.headline.copyWith(
              fontSize: 26,
              color: AppTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
