import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/iss_notification_service.dart';
import '../../data/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsRepository settingsRepository;

  const SettingsScreen({super.key, required this.settingsRepository});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _useMetric;
  late bool _launchAlerts;
  late bool _issPassAlerts;
  bool _issScheduling = false;

  @override
  void initState() {
    super.initState();
    _useMetric = widget.settingsRepository.useMetric;
    _launchAlerts = widget.settingsRepository.launchAlertsEnabled;
    _issPassAlerts = widget.settingsRepository.issPassAlertsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Metric Units'),
            subtitle: Text(_useMetric
                ? 'Display distance in km and altitude in km'
                : 'Display distance in miles and altitude in mi'),
            value: _useMetric,
            onChanged: (bool value) async {
              await widget.settingsRepository.setUseMetric(value);
              setState(() {
                _useMetric = value;
              });
            },
          ),
          const Divider(color: AppTheme.surfaceBorder, height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('NOTIFICATIONS',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
          ),
          SwitchListTile(
            title: const Text('Launch Alerts'),
            subtitle: const Text(
                'Notify me 15 minutes before a launch I\'ve favorited'),
            value: _launchAlerts,
            onChanged: (bool value) async {
              await widget.settingsRepository.setLaunchAlertsEnabled(value);
              setState(() {
                _launchAlerts = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('ISS Flyover Alerts'),
            subtitle: Text(_issScheduling
                ? 'Finding the next pass over your location...'
                : 'Notify me 5 minutes before the ISS is visible overhead'),
            value: _issPassAlerts,
            onChanged: (bool value) async {
              await widget.settingsRepository.setIssPassAlertsEnabled(value);
              setState(() {
                _issPassAlerts = value;
                _issScheduling = value;
              });
              await IssNotificationService().refreshSchedule();
              if (mounted) setState(() => _issScheduling = false);
            },
          ),
        ],
      ),
    );
  }
}
