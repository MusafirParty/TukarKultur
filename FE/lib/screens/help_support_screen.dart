import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF7),
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFAF7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.27,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Help Section
            Text(
              'Quick Help',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            _buildHelpTile(
              Icons.help_outline,
              'FAQ',
              'Find answers to common questions',
              () => _showFAQDialog(context),
            ),

            _buildHelpTile(
              Icons.book,
              'User Guide',
              'Learn how to use TukarKultur',
              () => _showUserGuideDialog(context),
            ),

            _buildHelpTile(
              Icons.video_library,
              'Video Tutorials',
              'Watch helpful video guides',
              () => _showVideoTutorialsDialog(context),
            ),

            SizedBox(height: 32),

            // Contact Support
            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            _buildHelpTile(
              Icons.chat,
              'Live Chat',
              'Chat with our support team',
              () => _showLiveChatDialog(context),
            ),

            _buildHelpTile(
              Icons.email,
              'Email Support',
              'Send us an email',
              () => _showEmailSupportDialog(context),
            ),

            _buildHelpTile(
              Icons.phone,
              'Phone Support',
              'Call our support hotline',
              () => _showPhoneSupportDialog(context),
            ),

            SizedBox(height: 32),

            // Report Issues
            Text(
              'Report Issues',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),

            _buildHelpTile(
              Icons.bug_report,
              'Report a Bug',
              'Let us know about technical issues',
              () => _showReportBugDialog(context),
            ),

            _buildHelpTile(
              Icons.flag,
              'Report Content',
              'Report inappropriate content',
              () => _showReportContentDialog(context),
            ),

            _buildHelpTile(
              Icons.feedback,
              'Send Feedback',
              'Share your thoughts and suggestions',
              () => _showFeedbackDialog(context),
            ),

            SizedBox(height: 32),

            // App Information
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffe8e0cf)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow('App Version', '1.0.0'),
                  _buildInfoRow('Build Number', '1'),
                  _buildInfoRow('Last Updated', 'January 2025'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _checkForUpdates(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9C854A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Check for Updates'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Emergency Contact
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFFEBEE),
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Emergency Support',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you\'re experiencing harassment or safety concerns, contact us immediately.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showEmergencyDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Emergency Contact'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffe8e0cf)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF9C854A), size: 24),
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
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
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
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How do I find people near me?'),
              SizedBox(height: 4),
              Text('A: Use the map feature to discover users in your area.'),
              SizedBox(height: 16),
              Text('Q: How do I report inappropriate behavior?'),
              SizedBox(height: 4),
              Text('A: Use the report feature in any chat or profile.'),
              SizedBox(height: 16),
              Text('Q: Can I change my location?'),
              SizedBox(height: 4),
              Text('A: Yes, update your location in profile settings.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserGuideDialog(BuildContext context) {
    _showFeatureDialog(context, 'User Guide', 'Comprehensive user guide coming soon!');
  }

  void _showVideoTutorialsDialog(BuildContext context) {
    _showFeatureDialog(context, 'Video Tutorials', 'Video tutorials will be available soon!');
  }

  void _showLiveChatDialog(BuildContext context) {
    _showFeatureDialog(context, 'Live Chat', 'Live chat support will be available soon!');
  }

  void _showEmailSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Email Support'),
        content: Text('Send us an email at:\nsupport@tukarkultur.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPhoneSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Phone Support'),
        content: Text('Call us at:\n+1 (555) 123-4567\n\nAvailable 24/7'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showReportBugDialog(BuildContext context) {
    _showFeatureDialog(context, 'Report Bug', 'Bug reporting system coming soon!');
  }

  void _showReportContentDialog(BuildContext context) {
    _showFeatureDialog(context, 'Report Content', 'Content reporting system coming soon!');
  }

  void _showFeedbackDialog(BuildContext context) {
    _showFeatureDialog(context, 'Send Feedback', 'Feedback system coming soon!');
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Support'),
        content: Text('For immediate assistance:\n\nEmail: emergency@tukarkultur.com\nPhone: +1 (555) 911-HELP\n\nWe take safety seriously and respond to emergencies within 1 hour.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _checkForUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have the latest version!'),
        backgroundColor: Color(0xFF9C854A),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
