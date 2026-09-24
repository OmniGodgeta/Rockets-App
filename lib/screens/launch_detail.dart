import 'package:flutter/material.dart';

/// Launch detail screen showing full launch information
class LaunchDetail extends StatefulWidget {
  final double progress;
  final String missionName;
  final String rocketName;
  final String location;
  final DateTime launchTime;
  final String status;

  const LaunchDetail({
    super.key,
    required this.progress,
    required this.missionName,
    required this.rocketName,
    required this.location,
    required this.launchTime,
    required this.status,
  });

  @override
  State<LaunchDetail> createState() => _LaunchDetailState();
}

class _LaunchDetailState extends State<LaunchDetail> {
  bool _isWatching = false;
  String _currentStream = 'Planetary Radio LIVE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.missionName),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFF00A1DE),
      ),
      body: CustomScrollView(
        slivers: [
          _buildVideoHeader(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(),
                _buildTimelineSection(),
                _buildOrbitData(),
                _buildPayloadInfo(),
                _buildComments(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoHeader() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: const Color(0xFF1C1C1C),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1C1C1C),
                const Color(0xFF0D0D0D),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: VideoPlayerPlaceholder(
                  isLive: widget.progress > 0 && widget.progress < 1,
                ),
              ),
              if (widget.progress > 0)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _currentStream,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.play_circle, color: Color(0xFF00A1DE)),
                                const SizedBox(width: 4),
                                Text(
                                  _getStreamQuality(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.progress > 0)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStreamButton(
                        'YouTube',
                        Icon(Icons.youtub
                      ),
                      _buildStreamButton(
                        'NASA TV',
                        Icon(Icons.cloud, color: const Color(0xFF00A1DE)),
                      ),
                      _buildStreamButton(
                        'SpaceX',
                        Icon(Icons.rocket_launch, color: const Color(0xFFC0392B)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isWatching ? Icons.pause : Icons.play_arrow),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.status == 'Success'
                      ? Icons.check_circle
                      : widget.status == 'Failed'
                          ? Icons.block
                          : Icons.rocket_launch,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusText(),
                      ),
                    ),
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(0).toIso8601String().split(' ')[0],
                      style: TextStyle(color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '_getRemaining()',
                    style: TextStyle(
                      color: const Color(0xFF00A1DE),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '1h 23m',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar(),
          const SizedBox(height: 12),
          Text(
            'Rocket: ${widget.rocketName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: const Color(0xFF00A1DE), size: 16),
              const SizedBox(width: 4),
              Text(
                widget.location,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time, color: const Color(0xFFF39C12), size: 16),
              const SizedBox(width: 4),
              Text(
                widget.launchTime.toString(),
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: widget.progress / 100,
      minHeight: 8,
      backgroundColor: Colors.white.withOpacity(0.1),
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC0392B)),
    );
  }

  Widget _buildTimelineSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00A1DE),
            ),
          ),
          const SizedBox(height: 8),
          _buildTimelineRow('T-minus 24h', 'Payload Integration Complete', Icons.check_circle, const Color(0xFF27AE60)),
          _buildTimelineRow('T-minus 12h', 'Final System Check', Icons.check_circle, const Color(0xFF27AE60)),
          _buildTimelineRow('T-minus 6h', 'Pre-launch Briefing', Icons.event, Colors.white),
          _buildTimelineRow('T-minus 1h', 'Launch Vehicle Arrival', Icons.rocket_launch, Colors.white),
          _buildTimelineRow('T-minus 15m', 'Hold Down Timer', Icons.access_time, Colors.white.withOpacity(0.5)),
          _buildTimelineRow('T+0', 'Launch', Icons.rocket_launch, const Color(0xFFC0392B)),
          _buildTimelineRow('T+30m', 'Max Q Pass', Icons.straighten, Colors.white.withOpacity(0.5)),
          _buildTimelineRow('T+12h', 'Orbit Insertion', Icons.fiber_manual_record, Colors.white.withOpacity(0.5)),
          _buildTimelineRow('T+24h', 'Mission Review', Icons.groups, Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
    String time,
    String event,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color, width: 1),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  event,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitData() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orbital Parameters',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00A1DE),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orbit Type',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    Text(
                      'LEO (Low Earth Orbit)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '342 km',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '347 km',
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inclination',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    Text(
                      '51.6°',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '18h 56m',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Period',
                      style: TextStyle(color: Colors.white.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          value: 0.73,
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Orbit',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Row(
                    children: ['24.6°', 'RAAN'].map((label) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '',
                          style: TextStyle(color: Colors.white.withOpacity(0.3)),
                        ),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayloadInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payload',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00A1DE),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description, color: const Color(0xFFC0392B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Falcon 9 + Dragon',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '2,014 kg to Orbit',
                            style: TextStyle(color: Colors.white.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.space_dashboard, color: const Color(0xFFF39C12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Starlink Group 7-17',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '5,949 satellites',
                            style: TextStyle(color: Colors.white.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.nature_people, color: const Color(0xFF27AE60)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dragon Demo 2 - Crew 2025',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '6,900 kg capacity',
                            style: TextStyle(color: Colors.white.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discussion',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00A1DE),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 40, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  Text(
                    '54.2K watching',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A1DE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rocket_launch, color: const Color(0xFF00A1DE), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Official SpaceX Stream',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00A1DE),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0392B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, color: const Color(0xFFC0392B), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'YouTube Live',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFC0392B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamButton(
    String label,
    Widget icon,
  ) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStreamQuality() {
    if (widget.progress == 0) return 'PRE-LAUNCH';
    if (widget.progress == 100) return 'MISSION COMPLETE';
    switch (widget.status) {
      case 'In Progress':
        return 'LIVE • 128Kbps';
      case 'Success':
        return 'MISSION COMPLETE • REPLAY';
      case 'Failed':
        return 'FAILED • NO STREAM';
      default:
        return 'SCHEDULED';
    }
  }

  Color _getStreamColor() {
    switch (widget.status) {
      case 'In Progress':
        return const Color(0xFFC0392B);
      case 'Success':
        return const Color(0xFF27AE60);
      case 'Failed':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF6B7A7D);
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case 'Success':
        return const Color(0xFF27AE60);
      case 'Failed':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFFE74C3C);
    }
  }

  TextStyle _getStatusText() {
    switch (widget.status) {
      case 'Success':
        return const TextStyle(color: Color(0xFF27AE60));
      case 'Failed':
        return const TextStyle(color: Color(0xFFD32F2F));
      default:
        return const TextStyle(color: Color(0xFFC0392B));
    }
  }

  String _getRemaining() {
    switch (widget.status) {
      case 'In Progress':
        return '1h 23m';
      case 'Failed':
        return 'FAILED';
      default:
        return 'TBD';
    }
  }
}

/// Video player placeholder for launch stream
class VideoPlayerPlaceholder extends StatelessWidget {
  final bool isLive;

  const VideoPlayerPlaceholder({
    super.key,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLive) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B0000),
              const Color(0xFFC0392B),
              const Color(0xFFE74C3C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1C1C1C),
              const Color(0xFF0D0D0D),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 64, color: Colors.white30),
              const SizedBox(height: 16),
              const Text(
                'Launch Stream',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
