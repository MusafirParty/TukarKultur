import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          'Profile',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.27),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () => _showFeatureDialog(context, 'Edit Profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8C4A0), // Peach color
              ),
              child: ClipOval(
                child: Image.network(
                  '/placeholder.svg?height=120&width=120',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFFE8C4A0),
                      child: Center(
                        child: Text(
                          'S',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // Name and Location
            Text(
              'Sophia Carter',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.27),
            ),
            Text(
              'San Francisco, CA',
              style: TextStyle(
                  fontSize: 16, color: Color(0xFF9C854A), height: 1.5),
            ),
            Text(
              'Joined 2021',
              style: TextStyle(
                  fontSize: 16, color: Color(0xFF9C854A), height: 1.5),
            ),
            SizedBox(height: 32),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('120', 'Interactions'),
                _buildStatColumn('4.8', 'Avg. Rating'),
                _buildStatColumn('95%', 'Response Rate'),
              ],
            ),
            SizedBox(height: 40),

            // Settings Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16),

            _buildSettingsItem(
              Icons.person_outline,
              'Edit Profile',
              'Edit your name, bio, and preferences',
            ),
            SizedBox(height: 16),
            _buildSettingsItem(
              Icons.notifications_outlined,
              'Notifications',
              'Manage your notification settings',
            ),
            SizedBox(height: 16),
            _buildSettingsItem(
              Icons.security_outlined,
              'Privacy & Security',
              'Control your privacy settings',
            ),
            SizedBox(height: 16),
            _buildSettingsItem(
              Icons.help_outline,
              'Help & Support',
              'Get help and contact support',
            ),
            SizedBox(height: 16),
            _buildSettingsItem(
              Icons.info_outline,
              'About',
              'App version and information',
            ),
            SizedBox(height: 16),
            _buildSettingsItem(
              Icons.logout_outlined,
              'Sign Out',
              'Sign out of your account',
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xffe8e0cf), // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(8), // Border radius
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.25),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style:
                TextStyle(fontSize: 14, color: Color(0xFF9C854A), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle,
      {Color? textColor}) {
    return Row(
      children: [
        Icon(icon, color: textColor ?? Colors.black, size: 24),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('This feature will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Community App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A platform for cultural exchange and community building.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Signed out successfully')),
              );
            },
            child: Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
