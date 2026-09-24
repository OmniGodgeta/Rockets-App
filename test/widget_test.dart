import 'package:flutter_test/flutter_test.dart';

import 'package:rockets/main.dart';
import 'package:rockets/data/settings_repository.dart';

// Simple fake for testing without external dependencies
class FakeSettingsRepository extends SettingsRepository {
  bool _useMetric = true;

  @override
  Future<void> init() async {}

  @override
  bool get useMetric => _useMetric;

  @override
  Future<void> setUseMetric(bool value) async {
    _useMetric = value;
  }
}

void main() {
  late FakeSettingsRepository fakeSettingsRepository;

  setUp(() {
    fakeSettingsRepository = FakeSettingsRepository();
  });

  testWidgets('App launches and shows the bottom navigation sections', (WidgetTester tester) async {
    await tester.pumpWidget(RocketsApp(settingsRepository: fakeSettingsRepository));
    await tester.pump();

    expect(find.text('ROCKETS'), findsWidgets);
    expect(find.text('SATELLITES'), findsOneWidget);
    expect(find.text('SOLAR SYSTEM'), findsOneWidget);
    expect(find.text('NEWS'), findsOneWidget);
  });
}
