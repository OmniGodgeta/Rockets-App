import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../data/astronaut_repository.dart';
import '../../models/astronaut.dart';

/// Who is in space right now, grouped by station and by the flight that took
/// them up (Launch Library 2).
class PeopleInSpaceScreen extends StatefulWidget {
  const PeopleInSpaceScreen({super.key});

  @override
  State<PeopleInSpaceScreen> createState() => _PeopleInSpaceScreenState();
}

class _PeopleInSpaceScreenState extends State<PeopleInSpaceScreen> {
  final _repo = AstronautRepository();
  late Future<List<Astronaut>> _people = _repo.fetchInSpace();

  Future<void> _refresh() async {
    final f = _repo.fetchInSpace(force: true);
    setState(() => _people = f);
    // Leave a failed refresh as an error on the Future. Swallowing it into
    // an empty list made the screen claim nobody is in space.
    try {
      await f;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PEOPLE IN SPACE')),
      body: FutureBuilder<List<Astronaut>>(
        future: _people,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.accent));
          }
          if (snap.hasError || snap.data == null) {
            return _Message(
              "Couldn't load the crew list. Pull down to try again.",
              onRefresh: _refresh,
            );
          }
          final now = DateTime.now();
          final crew = snap.data!.where((a) => !a.isStarman).toList();
          final starman = snap.data!.where((a) => a.isStarman).toList();

          // station -> mission -> people
          final byStation = <String, Map<String, List<Astronaut>>>{};
          for (final a in crew) {
            byStation
                .putIfAbsent(a.station, () => {})
                .putIfAbsent(a.mission, () => [])
                .add(a);
          }
          final stations = byStation.keys.toList()
            ..sort((a, b) => byStation[b]!.values
                .fold<int>(0, (n, l) => n + l.length)
                .compareTo(
                    byStation[a]!.values.fold<int>(0, (n, l) => n + l.length)));

          return RefreshIndicator(
            color: AppTheme.accent,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _Headline(count: crew.length, stations: stations.length),
                if (_repo.usedStaleCache)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Offline or rate-limited: showing the last list we got.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                for (final station in stations) ...[
                  _StationHeader(
                    station,
                    byStation[station]!.values
                        .fold<int>(0, (n, l) => n + l.length),
                  ),
                  for (final e in (byStation[station]!.entries.toList()
                    ..sort((a, b) => (a.value.first.launchedAt ?? now)
                        .compareTo(b.value.first.launchedAt ?? now))))
                    _MissionCard(mission: e.key, crew: e.value, now: now),
                ],
                if (starman.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Also "in space": Starman, the mannequin in the Tesla '
                      'Roadster SpaceX launched in 2018, still orbiting the Sun.',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                if (_repo.fetchedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Updated ${DateFormat('MMM d, HH:mm').format(_repo.fetchedAt!)}'
                      ' · Launch Library 2',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.count, required this.stations});
  final int count;
  final int stations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$count',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  height: 1)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'people are off the planet right now, on $stations '
              '${stations == 1 ? 'station' : 'stations'}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _StationHeader extends StatelessWidget {
  const _StationHeader(this.name, this.count);
  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        '${name.toUpperCase()}  ·  $count',
        style: const TextStyle(
          color: AppTheme.accent,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard(
      {required this.mission, required this.crew, required this.now});
  final String mission;
  final List<Astronaut> crew;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final launched = crew.first.launchedAt;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text(
              [
                mission,
                if (launched != null)
                  'launched ${DateFormat('MMM d, y').format(launched.toLocal())}'
                      ' · day ${crew.first.daysUp(now) + 1} in orbit',
              ].join('  ·  '),
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          for (final a in crew) _PersonTile(a),
        ],
      ),
    );
  }
}

String _count(int n, String word) => '$n $word${n == 1 ? '' : 's'}';

String _days(int n) => _count(n, 'day');

class _PersonTile extends StatelessWidget {
  const _PersonTile(this.a);
  final Astronaut a;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.surfaceBorder,
        backgroundImage:
            a.imageUrl == null ? null : CachedNetworkImageProvider(a.imageUrl!),
        child: a.imageUrl == null
            ? const Icon(Icons.person, color: AppTheme.textSecondary)
            : null,
      ),
      title: Text(a.name, style: const TextStyle(color: AppTheme.textPrimary)),
      subtitle: Text(
        [
          a.agency,
          if (a.nationality.isNotEmpty) a.nationality,
          '${_days(a.careerDays)} in space in total',
        ].join(' · '),
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      onTap: a.bio == null || a.bio!.isEmpty
          ? null
          : () => showModalBottomSheet<void>(
                context: context,
                backgroundColor: AppTheme.surface,
                builder: (_) => SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          '${_count(a.flightsCount, 'flight')} · '
                          '${_count(a.spacewalks, 'spacewalk')} · '
                          '${_days(a.careerDays)} in space',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Text(a.bio!,
                            style:
                                const TextStyle(color: AppTheme.textPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {required this.onRefresh});
  final String text;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}
