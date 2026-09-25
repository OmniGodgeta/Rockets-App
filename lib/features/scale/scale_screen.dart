import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/universe_scale_data.dart';
import '../../utils/wikipedia_thumbnail.dart';

/// Scale of the Universe, rebuilt as a native slider instead of embedding
/// htwins.net/scale2 - that page (a) also serves a Google AdSense banner
/// (confirmed by inspecting its markup directly) and (b) is built around
/// mouse-hover tutorial hints and an HTML <dialog> start screen that didn't
/// reliably render/respond to touch in Android WebView, which is what
/// actually caused the "doesn't load" report - the page loads, it just never
/// gets past its own desktop-oriented start screen on a phone.
///
/// Now covers asteroids through planets, dwarf stars/black holes, the
/// largest known stars, supermassive black holes, and a dwarf galaxy - not
/// just the original particle-to-observable-universe span - each with a
/// real reference photo, and a "COMPARE" mode to pick several items and see
/// them side by side to scale.
class ScaleScreen extends StatefulWidget {
  const ScaleScreen({super.key});

  @override
  State<ScaleScreen> createState() => _ScaleScreenState();
}

class _ScaleScreenState extends State<ScaleScreen> {
  late double _sliderValue;
  bool _compareMode = false;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCALE OF THE UNIVERSE'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _compareMode = !_compareMode;
              if (!_compareMode) _selected.clear();
            }),
            child: Text(
              _compareMode ? 'DONE' : 'COMPARE',
              style: const TextStyle(color: AppTheme.accent),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _compareMode ? _buildCompareMode() : _buildSliderMode(),
      ),
    );
  }

  Widget _buildSliderMode() {
    final index = _sliderValue.round().clamp(0, universeScaleData.length - 1);
    final item = universeScaleData[index];
    final logSize = math.log(item.sizeMeters) / math.ln10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WikipediaThumbnail(
                      wikipediaTitle: item.wikipediaTitle, size: 96),
                  const SizedBox(height: 16),
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
                    ? () =>
                        setState(() => _sliderValue = (index - 1).toDouble())
                    : null,
              ),
              Expanded(
                child: Slider(
                  value: _sliderValue,
                  min: 0,
                  max: (universeScaleData.length - 1).toDouble(),
                  divisions: universeScaleData.length - 1,
                  activeColor: AppTheme.accent,
                  onChanged: (value) => setState(() => _sliderValue = value),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppTheme.textPrimary),
                onPressed: index < universeScaleData.length - 1
                    ? () =>
                        setState(() => _sliderValue = (index + 1).toDouble())
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
    );
  }

  Widget _buildCompareMode() {
    final selectedItems = _selected.toList()..sort();
    return Column(
      children: [
        Expanded(
          child: selectedItems.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Pick a few objects below to see them side by side, to scale.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              : _CompareView(indices: selectedItems),
        ),
        const Divider(height: 1, color: AppTheme.surfaceBorder),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            itemCount: universeScaleData.length,
            itemBuilder: (context, index) {
              final item = universeScaleData[index];
              final isSelected = _selected.contains(index);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) {
                    _selected.remove(index);
                  } else if (_selected.length < 6) {
                    _selected.add(index);
                  }
                }),
                child: Container(
                  width: 84,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accent
                          : AppTheme.surfaceBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WikipediaThumbnail(
                          wikipediaTitle: item.wikipediaTitle, size: 36),
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Renders the selected objects side by side on a single shared scale, so
/// their relative sizes are directly, honestly comparable.
class _CompareView extends StatelessWidget {
  final List<int> indices;

  const _CompareView({required this.indices});

  @override
  Widget build(BuildContext context) {
    final items = indices.map((i) => universeScaleData[i]).toList();
    final largest = items.map((i) => i.sizeMeters).reduce(math.max);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBoxSize = constraints.maxHeight * 0.6;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final item in items)
                _CompareItem(item: item, largest: largest, maxBoxSize: maxBoxSize),
            ],
          ),
        );
      },
    );
  }
}

class _CompareItem extends StatelessWidget {
  final UniverseScaleItem item;
  final double largest;
  final double maxBoxSize;

  const _CompareItem({
    required this.item,
    required this.largest,
    required this.maxBoxSize,
  });

  @override
  Widget build(BuildContext context) {
    // Circles scaled LINEARLY by the ratio to the largest selected item -
    // not by area - so the comparison is honestly to scale, floored only so
    // a tiny object next to a galaxy stays visible as a dot at all.
    final ratio = item.sizeMeters / largest;
    final boxSize = (maxBoxSize * ratio).clamp(6.0, maxBoxSize);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: maxBoxSize,
            width: 110,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withValues(alpha: 0.25),
                  border: Border.all(color: AppTheme.accent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          WikipediaThumbnail(wikipediaTitle: item.wikipediaTitle, size: 40),
          const SizedBox(height: 6),
          SizedBox(
            width: 110,
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
