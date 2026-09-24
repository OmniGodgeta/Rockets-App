import 'package:flutter/material.dart';
import '../../data/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsRepository settingsRepository;

  const SettingsScreen({super.key, required this.settingsRepository});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _useMetric;

  @override
  void initState() {
    super.initState();
    _useMetric = widget.settingsRepository.useMetric;
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
            subtitle: Text(_useMetric ? 'Display distance in km and altitude in km' : 'Display distance in miles and altitude in mi'),
            value: _useMetric,
            onChanged: (bool value) async {
              await widget.settingsRepository.setUseMetric(value);
              setState(() {
                _useMetric = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
