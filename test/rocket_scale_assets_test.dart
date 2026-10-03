import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rockets/data/rocket_scale_data.dart';
import 'package:rockets/features/rocket_scale/rocket_scale_screen.dart';

void main() {
  test('bundled rocket diagrams are PNGs with an alpha channel', () {
    final missing = rocketScaleData
        .where((rocket) => rocket.assetImage == null)
        .map((rocket) => rocket.name)
        .toList();
    // Rechecked on Wikimedia Commons 2026-10-03. No transparent side-view
    // diagram exists for these two, so they stay on the Wikipedia photo.
    expect(missing, ['H3', 'Starship + Super Heavy (V2)']);

    for (final rocket in rocketScaleData) {
      final path = rocket.assetImage;
      if (path == null) continue;
      final bytes = File(path).readAsBytesSync();
      expect(bytes[0], 0x89, reason: '$path is not a PNG');
      expect(String.fromCharCodes(bytes.sublist(12, 16)), 'IHDR');
      // IHDR color type: 4 = gray+alpha, 6 = RGBA.
      final colorType = bytes[25];
      expect(colorType == 4 || colorType == 6, isTrue,
          reason: '$path has no alpha (color type $colorType)');
    }
  });

  testWidgets('rocket size comparison lays out on a phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: RocketScaleScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);

    // Wide enough that every rocket in the row is built.
    await tester.binding.setSurfaceSize(const Size(4000, 800));
    await tester.pumpWidget(const MaterialApp(home: RocketScaleScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Long March 5'), findsOneWidget);
    expect(find.text('Atlas V'), findsOneWidget);
    expect(find.text('Delta IV Heavy'), findsOneWidget);
  });
}
