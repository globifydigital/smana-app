import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ClubsScreen extends StatelessWidget {
  const ClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: const Text('Clubs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildClubCard(
            'Spice Sports Bar',
            'Live sports and drinks',
            'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?q=80&w=1000',
          ),
          _buildClubCard(
            'Sky Lounge',
            'Rooftop views',
            'https://images.unsplash.com/photo-1514362545857-3bc16549766b?q=80&w=1000',
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(String title, String desc, String imgUrl) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imgUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(desc, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
