import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/launch.dart';
import 'models/rocket.dart';
import 'api_services/api_service.dart';
import 'utils/app.dart';
import 'pages/launch_schedule_page.dart';
import 'pages/launch_details_page.dart';
import 'pages/video_player_page.dart';
import 'pages/rockets_list_page.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Future<List<Launch>> _launches;
  late Future<List<Rocket>> _rockets;
  String? selectedLaunchId;
  String? selectedRocketId;

  @override
  void initState() {
    super.initState();
    _launches = ApiService.getSpaceXLaunches();
    _rockets = ApiService.getRockets();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rockets 🚀',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder<List<Launch>>(
        future: _launches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          }

          final launches = snapshot.data ?? [];
          final upcoming = launches.where((l) => l.upcoming).toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Rocket Launcher'),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '🚀 Rocket Launcher',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${upcoming.length} upcoming launches',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ...launches.take(10).map((launch) => Card(
                  child: ListTile(
                    title: Text(launch.missionName),
                    subtitle: Text(_formattedDate(launch.dateUtc)),
                    onTap: () {
                      setState(() {
                        selectedLaunchId = launch.id;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LaunchDetailsPage(launch: launch),
                        ),
                      );
                    },
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formattedDate(String dateUtc) {
    try {
      final date = DateTime.parse(dateUtc);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Date unavailable';
    }
  }
}
