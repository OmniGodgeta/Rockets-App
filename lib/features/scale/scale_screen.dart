import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/universe_scale_data.dart';

/// Scale of the Universe, rebuilt as a native slider instead of embedding
/// htwins.net/scale2 - that page (a) also serves a Google AdSense banner
/// (confirmed by inspecting its markup directly) and (b) is built around
/// mouse-hover tutorial hints and an HTML <dialog> start screen that didn't
/// reliably render/respond to touch in Android WebView, which is what
/// actually caused the "doesn't load" report - the page loads, it just never
/// gets past its own desktop-oriented start screen on a phone.
class ScaleScreen extends StatefulWidget {
  const ScaleScreen({super.key});

  @override
  State<ScaleScreen> createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    // Start on "Human being" - a familiar anchor point.
    _sliderValue = universeScaleData
        .indexWhere((i) => i.name == 'Human being')
        .toDouble()
        .clamp(0, universeScaleData.length - 1);
  }

  String _formatSize(double meters) {
    if (meters < 1e-9) return '${(meters * 1e9).toStringAsFixed(2)} nm';
    if (meters < 1e-6) return '${(meters * 1e6).toStringAsFixed(2)} µm';
    if (meters < 1e-3) return '${(meters * 1e3).toStringAsFixed(2)} mm';
    if (meters < 1) return '${(meters * 100).toStringAsFixed(1)} cm';
    if (meters < 1000)
      return '${meters.toStringAsFixed(meters < 10 ? 2 : 1)} m';
    if (meters < 9.461e15) return '${(meters / 1000).toStringAsFixed(0)} km';
    final lightYears = meters / 9.461e15;
    if (lightYears < 1000)
      return '${lightYears.toStringAsFixed(2)} light-years';
    return '${lightYears.toStringAsExponential(2)} light-years';
  }

  @override
  Widget build(BuildContext context) {
    final index = _sliderValue.round().clamp(0, universeScaleData.length - 1);
    final item = universeScaleData[index];
    final logSize = math.log(item.sizeMeters) / math.ln10;

    return Scaffold(
      appBar: AppBar(title: const Text('SCALE OF THE UNIVERSE')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        style: AppTheme.headline.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Text(
                          _formatSize(item.sizeMeters),
                          style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '10^${logSize.toStringAsFixed(1)} meters',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: AppTheme.textPrimary),
                    onPressed: index > 0
                        ? () => setState(
                            () => _sliderValue = (index - 1).toDouble())
                        : null,
                  ),
                  Expanded(
                    child: Slider(
                      value: _sliderValue,
                      min: 0,
                      max: (universeScaleData.length - 1).toDouble(),
                      divisions: universeScaleData.length - 1,
                      activeColor: AppTheme.accent,
                      onChanged: (value) =>
                          setState(() => _sliderValue = value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: AppTheme.textPrimary),
                    onPressed: index < universeScaleData.length - 1
                        ? () => setState(
                            () => _sliderValue = (index + 1).toDouble())
                        : null,
                  ),
                ],
              ),
              const Text(
                'Planck length ← slide → observable universe',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
