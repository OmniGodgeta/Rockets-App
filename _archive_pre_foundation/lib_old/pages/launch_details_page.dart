import 'package:flutter/material.dart';
import '../models/launch.dart';
import '../models/rocket.dart';
import '../api_services/api_service.dart';

class LaunchDetailsPage extends StatelessWidget {
  final Launch launch;

  const LaunchDetailsPage({super.key, required this.launch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(launch.missionName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (launch.live) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.live_tv, color: Colors.red, size: 32),
                    const SizedBox(width: 16),
                    const Text(
                      'LIVE STREAM NOW',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.zero,
                    title: const Text(
                      'Launch Date:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateTime.parse(launch.dateUtc).toLocal().toString(),
                    ),
                  ),
                  if (launch.tbd || launch.isTentative) ...[
                    ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                      trailing: const Icon(Icons.warning, color: Colors.orange),
                      title: const Text('Tentative / To Be Determined'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    title: const Text('Rocket:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('More Information'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    title: const Text('Launch Site:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(launch.launchSites.isNotEmpty ? launch.launchSites.first : 'KSC Launch Complex 39A'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    title: const Text('Flight Number:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${launch.flightNumber ?? 'N/A'}'),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    title: const Text('Mission Details:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(launch.details),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Video Streams',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...launch.videoSources.map((source) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: source.isFallback ? Colors.grey : Colors.green,
                  child: Icon(Icons.play_arrow),
                ),
                title: Text(source.name),
                subtitle: Text(source.provider),
                trailing: ElevatedButton.small(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => VideoPlayerPage(videoId: source.url),
                      ),
                    );
                  },
                  child: const Text('Watch'),
                ),
              ),
            )),
            const SizedBox(height: 16),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                padding: const EdgeInsets.all(16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: const Text(
                      'Live Status',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (launch.success == 0) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.info_outline, size: 24),
                        ),
                        const Text('Mission status: Not launched yet'),
                      ],
                      if (launch.live) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.live_tv, color: Colors.white, size: 24),
                        ),
                        const Text(
                          'Currently Launching - Watch Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
