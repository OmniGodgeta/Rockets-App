import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<dynamic> launches = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchLaunches();
  }

  Future<void> fetchLaunches() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.spacexdata.com/v4/launches/upcoming'),
      );

      if (response.statusCode == 200) {
        setState(() {
          launches = List.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        setState(() {
          error = response.body;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rockets 🚀')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Rockets')),
        body: Center(child: Text('Error loading data: $error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Launches')),
      body: ListView.builder(
        itemCount: launches.length,
        itemBuilder: (context, index) {
          final launch = launches[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.rocket_launch, size: 40, color: Colors.red),
              title: Text(launch['name'] ?? 'Launch', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (launch['rocket'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text(launch['rocket']['name'] ?? 'Rocket'),
                    ),
                  if (launch['date_local'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(launch['date_local'].toString()),
                    ),
                ],
              ),
              onTap: () async {
                final videoUrl = launch['links']['youtube'];
                if (videoUrl != null && await canLaunchUrl(Uri.parse(videoUrl))) {
                  await launchUrl(Uri.parse(videoUrl), mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video link unavailable')),
                  );
                }
              },
              onLongPress: () async {
                final patchUrl = launch['links']['patch']?.toString();
                if (patchUrl != null && await canLaunchUrl(Uri.parse(patchUrl))) {
                  await launchUrl(Uri.parse(patchUrl), mode: LaunchMode.externalApplication);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchLaunches,
        child: const Icon(Icons.sync),
      ),
    );
  }
}
