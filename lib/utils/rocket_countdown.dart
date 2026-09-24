import 'dart:async';
import 'package:flutter/material.dart';

class RocketCountdown extends StatefulWidget {
  const RocketCountdown({super.key, required this.net});

  final DateTime net;

  @override
  State<RocketCountdown> createState() => _RocketCountdownState();
}

class _RocketCountdownState extends State<RocketCountdown> {
  late Timer _timer;
  late String _countdownText;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    if (!mounted) return;
    final now = DateTime.now();
    final diff = widget.net.difference(now);

    setState(() {
      if (diff.isNegative) {
        _countdownText = 'LAUNCHED';
      } else {
        final days = diff.inDays;
        final hours = diff.inHours % 24;
        final minutes = diff.inMinutes % 60;
        final seconds = diff.inSeconds % 60;

        if (days > 0) {
          _countdownText = 'T-${days}d ${hours}h ${minutes}m ${seconds}s';
        } else if (hours > 0) {
          _countdownText = 'T-${hours}h ${minutes}m ${seconds}s';
        } else if (minutes > 0) {
          _countdownText = 'T-${minutes}m ${seconds}s';
        } else {
          _countdownText = 'T-${seconds}s';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _countdownText,
      style: const TextStyle(
        color: Colors.redAccent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
