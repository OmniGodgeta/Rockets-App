import 'package:flutter_test/flutter_test.dart';

import 'package:rockets/main.dart';

void main() {
  testWidgets('App launches and shows the bottom navigation sections', (WidgetTester tester) async {
    await tester.pumpWidget(const RocketsApp());
    await tester.pump();

    expect(find.text('ROCKETS'), findsWidgets);
    expect(find.text('SATELLITES'), findsOneWidget);
    expect(find.text('SOLAR SYSTEM'), findsOneWidget);
    expect(find.text('NEWS'), findsOneWidget);
  });
}
