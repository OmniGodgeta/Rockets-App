import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
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
  List<String> manualLaunches = [
    'Starship IFT-6',
    'Starship IFT-5',
    'Starship IFT-4',
    'Starship IFT-3',
    'Starlink Batch 10-1',
    'Crew-8',
    'CST-26',
    'Crew-7',
    'Transporter-10',
    'Starlink Batch 9-2',
  ];

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
      // Fallback to predefined launches since SpaceX API doesn't support CORS
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        launches = manualLaunches;
        isLoading = false;
      });
      
      if (!mounted) return;
      
      setState(() {
        error = 'Fetched from local database';
      });
    } catch (e) {
      setState(() {
        error = e.toString();
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
        body: Center(child: Text('Data loaded: $error')),
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
              title: Text(launch, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('NASA/SpaceX Launch'),
              onTap: () async {
                // Open SpaceX YouTube channel with filtered search
                final videoUrl = 'https://www.youtube.com/results?search_query=spaceX+${launch}+live';
                if (await canLaunchUrl(Uri.parse(videoUrl))) {
                  await launchUrl(Uri.parse(videoUrl), mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video link unavailable')),
                  );
                }
              },
              onLongPress: () async {
                // Open patch notes search
                final patchUrl = 'https://x.com/spaceX/search?q=spaceX+${launch}';
                if (await canLaunchUrl(Uri.parse(patchUrl))) {
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
