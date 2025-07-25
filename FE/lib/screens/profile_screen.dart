import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';
import 'language_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        // If user is null (logged out), navigate to login screen
        if (user == null) {
          // Use WidgetsBinding to ensure navigation happens after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
          
          // Return a simple loading widget while navigation is happening
          return Scaffold(
            backgroundColor: Color(0xFFFCFAF7),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9C854A),
              ),
            ),
          );
        }
        
        return Scaffold(
          backgroundColor: Color(0xFFFCFAF7),
          appBar: AppBar(
            backgroundColor: Color(0xFFFCFAF7),
            elevation: 0,
            title: Text(
              'Profile',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.27),
            ),
            centerTitle: true,
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
                    child: user.profilePictureUrl != null
                        ? Image.network(
                            user.profilePictureUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildProfileInitial(user.fullName);
                            },
                          )
                        : _buildProfileInitial(user.fullName),
                  ),
                ),
                SizedBox(height: 16),

                // Name and Location
                Text(
                  user.fullName,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.27),
                ),
                if (user.city != null && user.country != null)
                  Text(
                    '${user.city}, ${user.country}',
                    style: TextStyle(
                        fontSize: 16, color: Color(0xFF9C854A), height: 1.5),
                  ),
                Text(
                  'Joined ${_formatJoinDate(user.createdAt)}',
                  style: TextStyle(
                      fontSize: 16, color: Color(0xFF9C854A), height: 1.5),
                ),
                SizedBox(height: 32),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn(user.totalInteractions.toString(), 'Interactions'),
                    _buildStatColumn(user.averageRating.toStringAsFixed(1), 'Avg. Rating'),
                  ],
                ),
                SizedBox(height: 40),

                // User Info Section if available
                if (user.bio != null || user.interests.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  if (user.bio != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffe8e0cf)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.bio!,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  
                  if (user.interests.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Interests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.interests.map((interest) => Chip(
                        label: Text(interest),
                        backgroundColor: Color(0xFFE8C4A0),
                      )).toList(),
                    ),
                  ],
                  SizedBox(height: 40),
                ],

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
                  context,
                  Icons.person_outline,
                  'Edit Profile',
                  'Edit your name, bio, and preferences',
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  context,
                  Icons.notifications_outlined,
                  'Notifications',
                  'Manage your notification settings',
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  context,
                  Icons.security_outlined,
                  'Privacy & Security',
                  'Control your privacy settings',
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                  'Get help and contact support',
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  context,
                  Icons.language_outlined,
                  'Language Settings',
                  'Change language and translation settings',
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  context,
                  Icons.info_outline,
                  'About',
                  'App version and information',
                ),
                SizedBox(height: 16),
                _buildSettingsItem(
                  context,
                  Icons.logout_outlined,
                  'Sign Out',
                  'Sign out of your account',
                  textColor: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileInitial(String fullName) {
    String initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
    return Container(
      color: Color(0xFFE8C4A0),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime joinDate) {
    return joinDate.year.toString();
  }

  Widget _buildStatColumn(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
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

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String subtitle,
      {Color? textColor}) {
    return GestureDetector(
      onTap: () {
        if (title == 'Sign Out') {
          _showSignOutDialog(context);
        } else if (title == 'About') {
          _showAboutDialog(context);
        } else if (title == 'Edit Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfileScreen()),
          );
        } else if (title == 'Notifications') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationsScreen()),
          );
        } else if (title == 'Privacy & Security') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrivacySecurityScreen()),
          );
        } else if (title == 'Help & Support') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelpSupportScreen()),
          );
        } else if (title == 'Language Settings') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LanguageSettingsScreen()),
          );
        } else {
          _showFeatureDialog(context, title);
        }
      },
      child: Row(
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
      ),
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
        title: Text('About TukarKultur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Connect through Culture - A platform for cultural exchange, meaningful conversations, and building global friendships.'),
            SizedBox(height: 8),
            Text('Discover new cultures, share your own, and create lasting connections with people around the world.'),
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
        title: Text(
          'Sign Out',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              
              try {
                // Perform logout
                await Provider.of<AuthProvider>(context, listen: false).logout();
                
                // Close loading indicator
                Navigator.pop(context);
                
                // Navigate to login screen and clear all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                // Close loading indicator if still showing
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to sign out: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
