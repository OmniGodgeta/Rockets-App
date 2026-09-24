import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/launch.dart';
import '../widgets/launch_item.dart';
import '../widgets/section_header.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rockets App'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Live Launches',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (true)  // Placeholder - add real data loading
                  LaunchItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
