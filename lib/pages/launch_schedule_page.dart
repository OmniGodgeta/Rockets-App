import 'package:flutter/material.dart';
import '../models/launch.dart';
import '../api_services/api_service.dart';

class LaunchSchedulePage extends StatefulWidget {
  const LaunchSchedulePage({super.key});

  @override
  State<LaunchSchedulePage> createState() => _LaunchSchedulePageState();
}

class _LaunchSchedulePageState extends State<LaunchSchedulePage> {
  final ApiService _api = ApiService();
  List<Launch> _launches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLaunches();
  }

  Future<void> _fetchLaunches() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final launches = await _api.getSpaceXLaunches();
      if (mounted) {
        setState(() {
          _launches = launches.where((l) => l.upcoming || l.live).toList().reversed.toList();
        });
      }
    } catch (e) {
      print('Error fetching launches: $e');
      if (mounted) {
        setState(() {
          _launches = MockData._mockOtherLaunches;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Launch Schedule'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLaunches,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _launches.isEmpty
                ? const Center(child: Text('No upcoming launches'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _launches.length,
                    itemBuilder: (ctx, i) {
                      final launch = _launches[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            launch.missionName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    launch.live ? Icons.live_tv : Icons.calendar_today,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formattedDate(launch.dateUtc),
                                  ),
                                ],
                              ),
                              if (launch.upcoming) ...[
                                const SizedBox(height: 2),
                                const Text(
                                  'Scheduled',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                              if (launch.live) ...[
                                const SizedBox(height: 2),
                                const Text(
                                  'LIVE NOW',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => LaunchDetailsPage(launch: launch),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _formattedDate(String dateUtc) {
    try {
      final date = DateTime.parse(dateUtc);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} UTC';
    } catch (_) {
      return 'Date unavailable';
    }
  }
}
