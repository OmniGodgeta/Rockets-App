import 'package:flutter/material.dart';

/// Favorites screen for bookmarked launches
class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔖 Favorited Launches'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFF00A1DE),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          _favoriteLaunches.length,
          (index) => _buildFavoriteCard(
            index: index,
            title: _favoriteLaunches[index]['title'] ?? '',
            subtitle: _favoriteLaunches[index]['subtitle'] ?? '',
            rating: _favoriteLaunches[index]['rating'] ?? '',
            onRemove: () {
              // Remove from favorites
            },
            onTap: () {
              // Navigate to launch detail
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: const Color(0xFF00A1DE),
      ),
    );
  }

  /// Build favorite card
  Widget _buildFavoriteCard({
    required int index,
    required String title,
    required String subtitle,
    required String rating,
    VoidCallback? onRemove,
    VoidCallback? onTap,
  }) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Icon(
                          Icons.rocket_launch,
                          color: const Color(0xFF00A1DE),
                        ),
                      ],
                    ),
                  ),
                  if (onRemove != null && index > 3)
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.3),
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: const Color(0xFF00A1DE),
                  size: 18,
                ),
                Text(
                  rating,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF00A1DE),
                  ),
                ),
                const Spacer(),
                if (index > 0)
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () {},
                  ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: onTap ?? () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sample favorite launches data
  static const List<Map<String, String>> _favoriteLaunches = [
    {
      'title': 'Starship SN15 Flight',
      'subtitle': 'Kennedy Space Center',
      'rating': '⭐⭐⭐⭐⭐',
    },
    {
      'title': 'Gaganyaan Test Flight',
      'subtitle': 'Satish Dhawan SC',
      'rating': '⭐⭐⭐⭐⭐',
    },
    {
      'title': 'Falcon 9 Starlink 7-23',
      'subtitle': 'Vandenberg SLC-4E',
      'rating': '⭐⭐⭐⭐',
    },
    {
      'title': 'Ariane 6 Maiden Flight',
      'subtitle': 'Guiana Space Center',
      'rating': '⭐⭐⭐⭐⭐',
    },
  ];
}
