import 'package:flutter/material.dart';

/// Settings screen for app configuration
class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFF00A1DE),
        elevation: 0,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(
              Icons.rocket_launch,
              size: 80,
              color: const Color(0xFF00A1DE),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rocket Launcher',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Profile section
          _buildSectionHeader('App Preferences'),
          const SizedBox(height: 8),
          
          _buildSettingsTile(Icons.notifications, 'Notifications', () {
            // Navigate to notification preferences
          }, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.wifi, 'WiFi Mode', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.data_usage, 'Data Saver', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          const SizedBox(height: 16),
          
          // Data sources section
          _buildSectionHeader('API Sources'),
          const SizedBox(height: 8),
          
          _buildSettingsTile(Icons.check_box, 'SpaceX API', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.check_box, 'NASA API', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.business, 'Rocket Lab API', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.public, 'Space Launch Report', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.cloud, 'China Space Agency', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.science, 'Indian Space Agency', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.science, 'Japan Aerospace', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.emoji_emotions, 'European Space', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          const SizedBox(height: 16),
          
          // Cache section
          _buildSectionHeader('Cache & Storage'),
          const SizedBox(height: 8),
          
          _buildSettingsTile(Icons.folder, 'Cache Size', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.cloud_off, 'Cache On', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.delete_sweep, 'Clear Cache', () {
            // Clear cache
          }, enabled: true, color: const Color(0xFF00A1DE)),
          const SizedBox(height: 16),
          
          // About section
          _buildSectionHeader('About'),
          const SizedBox(height: 8),
          
          _buildSettingsTile(Icons.info, 'Version', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.help_outline, 'Help', () {
            // Show help
          }, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.star, 'Rate App', () {
            // Rate app
          }, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.feedback, 'Feedback', () {
            // Show feedback
          }, enabled: true, color: const Color(0xFF00A1DE)),
          const SizedBox(height: 16),
          
          // Dark mode section
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 8),
          
          _buildSettingsTile(Icons.dark_mode, 'Dark Mode', () {
            // Toggle dark mode
          }, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.palette, 'Theme', () {}, enabled: true, color: const Color(0xFF00A1DE)),
          const SizedBox(height: 8),
          
          // Account section
          _buildSectionHeader('Account'),
          const SizedBox(height: 8),
          
          _buildSettingsTile(Icons.person, 'My Account', () {
            // Navigate to account
          }, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.notifications_outlined, 'Notifications', () {
            // Navigate to notifications
          }, enabled: true, color: const Color(0xFF00A1DE)),
          _buildSettingsTile(Icons.settings, 'Advanced Settings', () {
            // Navigate to advanced settings
          }, enabled: true, color: const Color(0xFF00A1DE)),
          const SizedBox(height: 8),
          
          const Divider(),
          const SizedBox(height: 8),
          
          _buildSectionHeader('Danger Zone'),
          const SizedBox(height: 8),
          
          _buildSettingsTile(
            Icons.warning,
            'Clear All Data',
            () {
              // Clear all data
            },
            enabled: false,
            color: const Color(0xFFD32F2F),
          ),
          _buildSettingsTile(
            Icons.lock,
            'Sign Out',
            () {
              // Sign out
            },
            enabled: false,
            color: const Color(0xFFD32F2F),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Build section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.7),
          letterSpacing: 1,
        ),
      ),
    );
  }

  /// Build settings tile
  Widget _buildSettingsTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    required bool enabled,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: enabled ? FontWeight.normal : FontWeight.w300,
        ),
      ),
      enabled: enabled,
      onTap: onTap,
    );
  }
}
