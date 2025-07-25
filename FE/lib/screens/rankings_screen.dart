import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RankingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Rankings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Users Section
            Text(
              'Top Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            _buildRankingItem(
              'Sophia Bennett',
              '120 interactions · 4.9 rating',
              true,
            ),
            _buildRankingItem(
              'Ethan Carter',
              '115 interactions · 4.8 rating',
              true,
            ),
            _buildRankingItem(
              'Olivia Davis',
              '110 interactions · 4.7 rating',
              true,
            ),
            SizedBox(height: 32),
            
            // All Users Section
            Text(
              'Your Friends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            _buildRankingItem(
              'Noah Evans',
              '105 interactions · 4.6 rating',
              false,
            ),
            _buildRankingItem(
              'Ava Foster',
              '100 interactions · 4.5 rating',
              false,
            ),
            _buildRankingItem(
              'Liam Gray',
              '95 interactions · 4.4 rating',
              false,
            ),
            _buildRankingItem(
              'Isabella Hayes',
              '90 interactions · 4.3 rating',
              false,
            ),
            _buildRankingItem(
              'Mason Ingram',
              '85 interactions · 4.2 rating',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(String name, String stats, bool isTopUser) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8C4A0),
            ),
            child: ClipOval(
              child: Image.network(
                '/placeholder.svg?height=48&width=48',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFFE8C4A0),
                    child: Center(
                      child: Text(
                        name[0],
                        style: TextStyle(
                          fontSize: 18,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  stats,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isTopUser)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
