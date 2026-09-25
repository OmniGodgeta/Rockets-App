import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class RocketCountdown extends StatefulWidget {
  const RocketCountdown({super.key, required this.net});

  final DateTime net;

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateRemaining());
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
      return Center(
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimeUnit(value: days, label: 'DAYS'),
            const SizedBox(width: 20),
            const Text(':', style: TextStyle(fontSize: 28, color: AppTheme.textSecondary)),
            const SizedBox(width: 20),
            _TimeUnit(value: hours, label: 'HRS'),
            const SizedBox(width: 20),
            const Text(':', style: TextStyle(fontSize: 28, color: AppTheme.textSecondary)),
            const SizedBox(width: 20),
            _TimeUnit(value: minutes, label: 'MIN'),
            const SizedBox(width: 20),
            const Text(':', style: TextStyle(fontSize: 28, color: AppTheme.textSecondary)),
            const SizedBox(width: 20),
            _TimeUnit(value: seconds, label: 'SEC'),
          ],
        ),
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
        Text(
          value.toString().padLeft(2, '0'),
          style: AppTheme.headline.copyWith(
            fontSize: 28,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
