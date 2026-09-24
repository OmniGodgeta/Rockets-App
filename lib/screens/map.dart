import 'package:flutter/material.dart';

/// World map page with Google Maps integration
class WorldMapPage extends StatelessWidget {
  const WorldMapPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Map'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFF00A1DE),
      ),
      body: Stack(
        children: [
          _buildMapContent(),
          _buildLaunchList(),
          _buildLegend(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.map),
        label: const Text('Browse Map'),
      ),
    );
  }

  Widget _buildMapContent() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'World Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Interactive launch tracking map',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaunchList() {
    return Positioned(
      top: 50,
      left: 50,
      child: Card(
        color: const Color(0xFFC0392B).withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.rocket_launch, color: const Color(0xFFC0392B)),
              title: const Text('Starship SN15'),
              subtitle: const Text('Kennedy Space Center'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.event, color: const Color(0xFFF39C12)),
              title: const Text('Starlink Group 7-23'),
              subtitle: const Text('Vandenberg SLC-4E'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: const Color(0xFF00A1DE)),
              title: const Text('Long March 7G'),
              subtitle: const Text('Jiuquan Satellite'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      top: 20,
      right: 16,
      child: Card(
        color: Colors.transparent,
        child: Column(
          children: [
            _buildLegendRow(
              icon: Icon(Icons.rocket_launch, color: const Color(0xFF00A1DE)),
              label: 'Live',
            ),
            _buildLegendRow(
              icon: Icon(Icons.event, color: const Color(0xFFF39C12)),
              label: 'Upcoming',
            ),
            _buildLegendRow(
              icon: Icon(Icons.location_on, color: const Color(0xFF00A1DE)),
              label: 'CNSA Launch',
            ),
            _buildLegendRow(
              icon: Icon(Icons.arrow_upward, color: const Color(0xFF27AE60)),
              label: 'Success',
            ),
            _buildLegendRow(
              icon: Icon(Icons.block, color: Colors.red),
              label: 'Failed',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow({
    required Widget icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
