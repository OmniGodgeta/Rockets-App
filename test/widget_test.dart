import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

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
  late Directory hiveTestDir;

  setUp(() async {
    fakeSettingsRepository = FakeSettingsRepository();
    // The real app initializes Hive via Hive.initFlutter() in main() before
    // runApp(); a widget test never runs main(), so LaunchRepository/
    // NewsRepository/SatelliteRepository's Hive.openBox() calls fail with
    // "You need to initialize Hive" unless we do it ourselves here, against
    // a throwaway temp directory.
    hiveTestDir = Directory.systemTemp.createTempSync('rockets_hive_test');
    Hive.init(hiveTestDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (hiveTestDir.existsSync()) {
      hiveTestDir.deleteSync(recursive: true);
    }
  });

  testWidgets('App launches and shows the bottom navigation sections',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(RocketsApp(settingsRepository: fakeSettingsRepository));
    await tester.pump();

    // Labels as they actually are today (root_shell.dart) - the previous
    // version of this test still expected 'SATELLITES'/'SOLAR SYSTEM' from
    // before the nav relabel to 'SATS'/'SOL', and never noticed the GALAXY
    // and UNIVERSE tabs added since. This test had been failing quietly for
    // a while - flutter test was never part of the routine verification
    // loop on this project.
    expect(find.text('ROCKETS'), findsWidgets);
    expect(find.text('SATS'), findsOneWidget);
    expect(find.text('SOL'), findsOneWidget);
    expect(find.text('GALAXY'), findsOneWidget);
    expect(find.text('UNIVERSE'), findsOneWidget);
    expect(find.text('NEWS'), findsOneWidget);
  });
}
