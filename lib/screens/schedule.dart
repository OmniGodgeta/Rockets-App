import 'package:flutter/material.dart';

/// Schedule page with calendar view
class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFF00A1DE),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // Show date picker
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header card
            _buildHeaderCard(),
            const SizedBox(height: 16),
            
            // Filter tabs
            _buildFilters(),
            const SizedBox(height: 8),
            
            // Upcoming launches list
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Launches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // Launch list items
            _buildLaunchScheduleItem(
              title: 'Falcon 9 - Starlink Group 7-23',
              time: '1:45 PM EST',
              provider: 'SpaceX',
              rocket: 'Falcon 9',
              status: 'Scheduled',
            ),
            const SizedBox(height: 8),
            _buildLaunchScheduleItem(
              title: 'Gaganyaan Mission 1',
              time: '10:45 PM IST',
              provider: 'ISRO',
              rocket: 'Gaganyaan',
              status: 'Scheduled',
            ),
            const SizedBox(height: 8),
            _buildLaunchScheduleItem(
              title: 'Ariane 6 Maiden Flight',
              time: '6:20 AM CET',
              provider: 'ESA',
              rocket: 'Ariane 6',
              status: 'Scheduled',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  /// Build header card
  Widget _buildHeaderCard() {
    return Card(
      color: const Color(0xFF1C1C1C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 2026-09-23',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'September 23, 2026',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    label: 'Today',
                    count: '4',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    label: 'This Week',
                    count: '12',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    label: 'This Month',
                    count: '24',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build filter bar
  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _filterChip('Show All', isActive: false),
          const SizedBox(width: 8),
          _filterChip('Upcoming', isActive: true),
          const SizedBox(width: 8),
          _filterChip('Past', isActive: false),
          const SizedBox(width: 8),
          const Spacer(),
          _filterChip('All Providers', isActive: false, icon: Icons.business),
          const SizedBox(width: 8),
          _filterChip('All Countries', isActive: false, icon: Icons.location_on),
          const SizedBox(width: 8),
          _filterChip('All Rockets', isActive: false, icon: Icons.rocket_launch),
        ],
      ),
    );
  }
  
  /// Build stat chip
  Widget _buildStatChip({
    required String label,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00A1DE),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00A1DE),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '• $label',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build filter chip
  Widget _filterChip(
    String label, {
    required bool isActive,
    IconData? icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
            ? const Color(0xFF00A1DE)
            : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 16, color: isActive ? Colors.white : null),
            if (icon != null) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : null,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build schedule item
  Widget _buildLaunchScheduleItem({
    required String title,
    required String time,
    required String provider,
    required String rocket,
    required String status,
  }) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rocket icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: getRocketColor(rocket),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: const Color(0xFF00A1DE),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF00A1DE),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: status == 'Scheduled' ? Colors.white : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get rocket color based on rocket type
  Color getRocketColor(String rocket) {
    switch (rocket.toLowerCase()) {
      case 'falcon 9':
      case 'falcon heavy':
      case 'starship':
        return const Color(0xFFC0392B);
      case 'long march':
        return const Color(0xFF00A1DE);
      case 'gaganayant':
      case 'gaganyaan':
        return const Color(0xFFE67E22);
      case 'ariane':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFF95A5A6);
    }
  }
  
  /// Get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF00A1DE);
      case 'launching':
        return const Color(0xFFE74C3C);
      case 'success':
        return const Color(0xFF27AE60);
      case 'failure':
        return const Color(0xFF7F8C8D);
      default:
        return const Color(0xFF95A5A6);
    }
  }
}
