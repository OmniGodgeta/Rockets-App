import 'package:flutter/material.dart';

/// Provider directory showing all launch providers
class ProviderDirectory extends StatelessWidget {
  const ProviderDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Launch Providers'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFF00A1DE),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Launch Providers',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore space launch capabilities from providers worldwide',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search providers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Providers grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _providers.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return _buildProviderCard(_providers[index]);
              },
            ),
            const SizedBox(height: 80),  // Bottom padding
          ],
        ),
      ),
    );
  }
  
  /// Build provider card
  Widget _buildProviderCard(Map<String, String> provider) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: InkWell(
        onTap: () {
          // Navigate to provider detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getProviderColor(provider['id'] ?? ''),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getProviderIcon(provider['id'] ?? ''),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (provider['abbreviation'] != null)
                          Text(
                            provider['abbreviation'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            // Description (truncated)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider['name'] ?? 'Description',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        provider['success_rate']?.toString() ?? '0%',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        provider['status'] ?? 'Active',
                        style: TextStyle(
                          color: const Color(0xFF00A1DE),
                        ),
                      ),
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
  
  /// Get provider icon based on country/agency
  IconData _getProviderIcon(String providerId) {
    switch (providerId.toLowerCase()) {
      case 'spacex':
        return Icons.rocket_launch;
      case 'nasa':
        return Icons.satellite;
      case 'cnsa':
        return Icons.space_dashboard;
      case 'esa':
        return Icons.business;
      case 'isro':
        return Icons.science;
      case 'jaxa':
        return Icons.science;
      case 'rocket_lab':
        return Icons.rocket_launch;
      case 'ariane':
        return Icons.west;
      case 'rosatom':
      case 'russian':
        return Icons.space_dashboard;
      default:
        return Icons.business;
    }
  }
  
  /// Get provider color based on name
  Color _getProviderColor(String providerId) {
    switch (providerId.toLowerCase()) {
      case 'spacex':
        return const Color(0xFFC0392B);
      case 'nasa':
        return const Color(0xFF0033A0);
      case 'cnsa':
        return const Color(0xFF00A1DE);
      case 'esa':
        return const Color(0xFF27AE60);
      case 'isro':
        return const Color(0xFF00A1DE);
      case 'jaxa':
        return const Color(0xFF004D99);
      case 'rocket_lab':
        return const Color(0xFFE74C3C);
      case 'ariane':
        return const Color(0xFF27AE60);
      case 'rosatom':
      case 'russian':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF95A5A6);
    }
  }
  
  /// Sample providers data
  List<Map<String, String>> get _providers => [
        {
          'name': 'SpaceX',
          'abbreviation': 'SpaceX',
          'status': 'Active',
          'success_rate': '95%',
        },
        {
          'name': 'NASA',
          'abbreviation': 'NASA',
          'status': 'Active',
          'success_rate': '97%',
        },
        {
          'name': 'CNSA',
          'abbreviation': 'CNSA',
          'status': 'Active',
          'success_rate': '91%',
        },
        {
          'name': 'ESA',
          'abbreviation': 'ESA',
          'status': 'Active',
          'success_rate': '92%',
        },
        {
          'name': 'ISRO',
          'abbreviation': 'ISRO',
          'status': 'Active',
          'success_rate': '100%',
        },
        {
          'name': 'JAXA',
          'abbreviation': 'JAXA',
          'status': 'Active',
          'success_rate': '94%',
        },
        {
          'name': 'Rocket Lab',
          'abbreviation': 'Rocket Lab',
          'status': 'Active',
          'success_rate': '87%',
        },
        {
          'name': 'Arianespace',
          'abbreviation': 'Arianespace',
          'status': 'Active',
          'success_rate': '90%',
        },
        {
          'name': 'Roscosmos',
          'abbreviation': 'Roscosmos',
          'status': 'Active',
          'success_rate': '89%',
        },
        {
          'name': 'Blue Origin',
          'abbreviation': 'Blue Origin',
          'status': 'Active',
          'success_rate': 'N/A',
        },
      ];
}
