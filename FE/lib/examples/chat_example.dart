import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class ChatExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TukarKultur Chat Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatPartnerId: 'partner_user_id_123',
                  chatPartnerName: 'Liam',
                  chatPartnerDistance: '1.2 miles away',
                ),
              ),
            );
          },
          child: Text('Start Chat with AI Integration'),
        ),
      ),
    );
  }
}

// Usage instructions for integrating with your app:
/*
1. Make sure your backend server is running on localhost:8080
2. Update the base URLs in api_service.dart and websocket_service.dart to match your server
3. Replace 'current_user_id' with actual user authentication
4. Navigate to ChatScreen like this:

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatScreen(
      chatPartnerId: 'actual_partner_id',
      chatPartnerName: 'Partner Name',
      chatPartnerDistance: '2.5 km away',
    ),
  ),
);

Features included:
- Real-time WebSocket chat
- AI welcome message on chat start
- AI responses triggered by keywords
- Cultural insights via menu
- Meetup suggestions
- AI assistant toggle
- Message timestamps
- Connection status handling
- Error handling and retry
*/
