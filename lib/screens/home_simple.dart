import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/launch.dart';
import '../models/favorite.dart';
import '../widgets/launch_item.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rockets App'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Live launches',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Empty view when no data
          if (Favorites.hive.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket, size: 64, color: Theme.of(context).primaryColor.withOpacity(0.2)),
                  SizedBox(height: 16),
                  Text('Connecting to launch providers...'),
                ],
              ),
            ),
          // TODO: Show actual launch list from Hive after loading
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
