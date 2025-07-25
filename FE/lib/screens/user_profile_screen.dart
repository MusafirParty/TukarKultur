import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userAvatar;
  final String? userLocation;
  final String? userPoints;
  final bool isNearbyUser;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.userLocation,
    this.userPoints,
    this.isNearbyUser = false,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
          widget.userName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showProfileOptions(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture and Basic Info
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8C4A0),
              ),
              child: Center(
                child: Text(
                  widget.userAvatar,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            Text(
              widget.userName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            if (widget.userLocation != null)
              Text(
                widget.userLocation!,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9C854A),
                ),
              ),

            if (widget.userPoints != null)
              Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFE8C4A0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.userPoints!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),

            SizedBox(height: 32),

            // 🏆 AI Cultural DNA Scanner - HACKATHON FEATURE
            _buildCulturalDNASection(),

            SizedBox(height: 16),

            // 🌉 Cultural Bridge Builder - HACKATHON FEATURE
            _buildCulturalBridgeSection(),

            SizedBox(height: 16),

            // Bio Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffe8e0cf)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Hello! I\'m passionate about cultural exchange and love meeting people from different backgrounds. I enjoy sharing stories about my culture and learning about others.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Interests
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffe8e0cf)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInterestChip('Cultural Food'),
                      _buildInterestChip('Traditional Music'),
                      _buildInterestChip('Language Exchange'),
                      _buildInterestChip('Local Festivals'),
                      _buildInterestChip('Art & History'),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startChat(),
                    icon: Icon(Icons.chat_bubble_outline),
                    label: Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF9C854A),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _sendFriendRequest(),
                    icon: Icon(Icons.person_add),
                    label: Text('Add Friend'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF9C854A),
                      side: BorderSide(color: Color(0xFF9C854A)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Additional Actions
            if (widget.isNearbyUser)
              Container(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _suggestMeetup(),
                  icon: Icon(Icons.location_on),
                  label: Text('Suggest Meetup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9C854A),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChip(String interest) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xffe8e0cf),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        interest,
        style: TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      ),
    );
  }

  // 🧬 Cultural DNA Scanner - HACKATHON FEATURE
  Widget _buildCulturalDNASection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9C854A), Color(0xFFBFA55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9C854A).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🧬',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cultural DNA Scanner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'AI-powered cultural compatibility analysis',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildCulturalDNAChart(),
          SizedBox(height: 12),
          _buildDNAInsight(),
        ],
      ),
    );
  }

  Widget _buildCulturalDNAChart() {
    return Column(
      children: [
        _buildDNABar('Collectivism vs Individualism', 0.75, '🤝'),
        _buildDNABar('High vs Low Context', 0.85, '💬'),
        _buildDNABar('Hierarchy vs Equality', 0.45, '👑'),
        _buildDNABar('Risk Taking vs Caution', 0.60, '🎲'),
      ],
    );
  }

  Widget _buildDNABar(String trait, double value, String emoji) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trait,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDNAInsight() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('🎯', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'High cultural compatibility! You both value community connections and detailed communication styles.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🌉 Cultural Bridge Builder - HACKATHON FEATURE
  Widget _buildCulturalBridgeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFCAB57A), Color(0xFFD4A574)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFCAB57A).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🌉',
                  style: TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cultural Bridge Builder',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'AI suggestions for meaningful connections',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildBridgeSuggestions(),
        ],
      ),
    );
  }

  Widget _buildBridgeSuggestions() {
    return Column(
      children: [
        _buildBridgeItem(
          '🍜',
          'Food Bridge',
          'Share traditional recipes from your cultures',
          'Both love culinary traditions',
        ),
        _buildBridgeItem(
          '🎵',
          'Music Exchange',
          'Create a playlist of folk songs from both cultures',
          'Common appreciation for traditional music',
        ),
        _buildBridgeItem(
          '📚',
          'Story Swap',
          'Exchange folktales and cultural legends',
          'Both enjoy cultural storytelling',
        ),
      ],
    );
  }

  Widget _buildBridgeItem(String emoji, String title, String suggestion, String reason) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    reason,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatPartnerId: widget.userId,
          chatPartnerName: widget.userName,
          chatPartnerDistance: widget.userLocation,
        ),
      ),
    );
  }

  void _sendFriendRequest() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to ${widget.userName}!'),
        backgroundColor: Color(0xFF9C854A),
      ),
    );
  }

  void _suggestMeetup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meetup suggestion sent to ${widget.userName}!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.flag),
              title: Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report submitted')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.block),
              title: Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User blocked')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}