import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rockets/features/moon/moon_screen.dart';

void main() {
  testWidgets('moon screen shows the phase and the next new and full moons',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MoonScreen()));
    expect(find.textContaining('% lit'), findsOneWidget);
    expect(find.textContaining('Next Full Moon'), findsOneWidget);
    expect(find.textContaining('Next New Moon'), findsOneWidget);
  });
}
