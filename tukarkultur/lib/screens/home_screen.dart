import 'package:flutter/material.dart';
import 'rankings_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Welcome back, Ryan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 32),
            
            // Nearby Users Section
            Text(
              'Nearby Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUserAvatar('Liam', 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%20from%202025-07-24%2016-42-14-4H6yDPRO72m4pG2CnzVgGbkLqhstEr.png'),
                _buildUserAvatar('Olivia', 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%20from%202025-07-24%2016-42-14-4H6yDPRO72m4pG2CnzVgGbkLqhstEr.png'),
                _buildUserAvatar('Noah', 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%20from%202025-07-24%2016-42-14-4H6yDPRO72m4pG2CnzVgGbkLqhstEr.png'),
              ],
            ),
            SizedBox(height: 32),
            
            // User Rankings Section
            Text(
              'User Rankings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            _buildRankingItem('You', '120 points', 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%20from%202025-07-24%2016-42-14-4H6yDPRO72m4pG2CnzVgGbkLqhstEr.png'),
            _buildRankingItem('Ava', '150 points', 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%20from%202025-07-24%2016-42-14-4H6yDPRO72m4pG2CnzVgGbkLqhstEr.png'),
            _buildRankingItem('Owen', '135 points', 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%20from%202025-07-24%2016-42-14-4H6yDPRO72m4pG2CnzVgGbkLqhstEr.png'),
            _buildRankingItem('Chloe', '110 points', 'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot%20from%202025-07-24%2016-42-14-4H6yDPRO72m4pG2CnzVgGbkLqhstEr.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String name, String imageUrl) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE8C4A0), // Peach color for avatar background
          ),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Color(0xFFE8C4A0),
                  child: Center(
                    child: Text(
                      name[0],
                      style: TextStyle(
                        fontSize: 24,
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
        SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(String name, String points, String imageUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8C4A0),
            ),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFFE8C4A0),
                    child: Center(
                      child: Text(
                        name[0],
                        style: TextStyle(
                          fontSize: 16,
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
          SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            points,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
