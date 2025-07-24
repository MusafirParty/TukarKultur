import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildChatItem(
            context,
            name: 'Liam',
            lastMessage: 'Perfect, I\'ll be there in 5 minutes.',
            time: '2m',
            unreadCount: 2,
            avatar: 'L',
            isOnline: true,
            partnerId: 'user_liam_123',
            distance: '1.2 miles away',
          ),
          _buildChatItem(
            context,
            name: 'Sari',
            lastMessage: 'Thanks for the cultural tips!',
            time: '1h',
            unreadCount: 0,
            avatar: 'S',
            isOnline: false,
            partnerId: 'user_sari_456',
            distance: '3.5 km away',
          ),
          _buildChatItem(
            context,
            name: 'Ahmed',
            lastMessage: 'The festival was amazing!',
            time: '3h',
            unreadCount: 1,
            avatar: 'A',
            isOnline: true,
            partnerId: 'user_ahmed_789',
            distance: '0.8 miles away',
          ),
          _buildChatItem(
            context,
            name: 'Yuki',
            lastMessage: 'Let\'s explore the temple together',
            time: '1d',
            unreadCount: 0,
            avatar: 'Y',
            isOnline: false,
            partnerId: 'user_yuki_012',
            distance: '2.1 km away',
          ),
          _buildChatItem(
            context,
            name: 'Maria',
            lastMessage: 'The cooking class was so fun!',
            time: '2d',
            unreadCount: 0,
            avatar: 'M',
            isOnline: true,
            partnerId: 'user_maria_345',
            distance: '4.2 miles away',
          ),
          SizedBox(height: 80), // Add spacing for bottom navigation
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatOptions(context),
        backgroundColor: Color(0xFFE6B800),
        child: Icon(Icons.add_comment, color: Colors.black),
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String name,
    required String lastMessage,
    required String time,
    required int unreadCount,
    required String avatar,
    required bool isOnline,
    required String partnerId,
    required String distance,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8C4A0),
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              lastMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2),
            Text(
              distance,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            if (unreadCount > 0) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFE6B800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatPartnerId: partnerId,
                chatPartnerName: name,
                chatPartnerDistance: distance,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNewChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Start a Conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.location_on, color: Colors.blue),
              ),
              title: Text('Find People Nearby'),
              subtitle: Text('Discover cultural exchange partners in your area'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to nearby people screen
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group, color: Colors.green),
              ),
              title: Text('Join Cultural Groups'),
              subtitle: Text('Connect with communities sharing your interests'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to groups screen
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.smart_toy, color: Colors.orange),
              ),
              title: Text('Chat with AI Assistant'),
              subtitle: Text('Get cultural insights and conversation tips'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatPartnerId: 'ai_assistant',
                      chatPartnerName: 'AI Cultural Assistant',
                      chatPartnerDistance: null,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
