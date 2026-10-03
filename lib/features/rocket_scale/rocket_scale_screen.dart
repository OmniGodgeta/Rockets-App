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
/// smallest to largest, with a transparent diagram (or a reference photo where
/// none was found) per rocket.
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
      appBar: AppBar(
        title: const Text('ROCKET SIZE COMPARISON'),
        actions: [
          IconButton(
            tooltip: 'Image credits',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showCredits(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Room under the bars: the list's 32 px vertical padding,
                // 8 px gap, a name of up to two lines and the height line.
                // 80 overflowed by up to 10 px on the two-line names
                // ("Starship + Super Heavy (V2)") at the tall end.
                final drawHeight = constraints.maxHeight - 104;
                final scaleFactor = drawHeight / tallest;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

/// The bundled diagrams are Wikimedia Commons files, several CC BY-SA, which
/// requires visible attribution. Mirrors assets/rockets/CREDITS.md.
const _credits = [
  ('Human', 'Sebastian Wallroth', 'CC0'),
  ('Electron', 'UnknownM1', 'CC BY-SA 4.0, outline added'),
  ('Soyuz-2', 'David S. F. Portree / NASA', 'Public domain, recoloured'),
  ('Ariane 5', 'Sylvain Comte', 'CC BY-SA 3.0'),
  ('Space Shuttle', 'NASA', 'Public domain, cropped'),
  ('Long March 5', 'Shujianyang', 'CC BY-SA 4.0, trimmed'),
  ('Atlas V', 'Wikimedia Commons', 'Public domain, cropped'),
  ('Ariane 6', 'ChiZeroOne', 'CC BY-SA 4.0, cropped'),
  ('Falcon 9 / Falcon Heavy', 'WDGraham', 'Attribution, cropped'),
  ('Delta IV Heavy', 'Tomáš Hruška', 'Public domain, cropped'),
  ('SLS', 'NASA/cbush', 'Public domain'),
  ('New Glenn', 'XYZtSpace', 'CC0'),
  ('Saturn V', 'charner1963', 'CC0'),
  ('Starship V3', 'FAA', 'Public domain'),
];

void _showCredits(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    builder: (context) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          const Text('DIAGRAMS FROM WIKIMEDIA COMMONS',
              style: TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          const Text('Rockets without a diagram use their Wikipedia photo.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          for (final (what, who, licence) in _credits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('$what: $who ($licence)',
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13)),
            ),
        ],
      ),
    ),
  );
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
    // The rocket's real height maps exactly to this box's height, via the
    // one shared scaleFactor every item in the row uses - this IS the fix
    // for the original "human looks nearly as tall as Falcon 9" bug. Width
    // is a fixed lane (not diameterMeters * scaleFactor): a real photo
    // stretched to a true diameter-accurate sliver (a 70 m x 3.7 m box is
    // ~19:1) would be squashed into an unrecognizable smear, which is worse
    // than not being to scale on that axis. Every item sits in the same
    // outer Column(mainAxisAlignment: end), so every box's BOTTOM edge - the
    // "ground" - lines up across the whole row; only the top edge moves,
    // which is what "aligned, standing on the same ground" actually means.
    // Floored so the smallest item (a 1.7 m human next to a 150 m rocket)
    // stays a visible sliver instead of a literal few-pixel line - still
    // dramatically smaller than the rockets, just not to the point of
    // disappearing.
    final drawHeight =
        (rocket.heightMeters * scaleFactor).clamp(14.0, double.infinity);
    const laneWidth = 96.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: laneWidth,
            height: drawHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppTheme.accent : AppTheme.surfaceBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              // SizedBox -> DecoratedBox both pass tight WxH constraints
              // straight through, so the image actually fills this
              // height-accurate box (BoxFit.contain scales the bitmap
              // within it) instead of rendering at its own natural size.
              child: rocket.assetImage != null
                  // Transparent side-view diagram: drawn top to bottom, so
                  // BoxFit.contain makes it fill the box's full height.
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: Image.asset(
                        rocket.assetImage!,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                    )
                  : WikipediaThumbnail(
                      wikipediaTitle: rocket.wikipediaTitle,
                      circular: false,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: laneWidth + 20,
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
