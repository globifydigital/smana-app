import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: const Text('Activities and Tourism')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActivityCard(
            'Explore Dubai',
            'Discover the charm of Dubai with guided city tours.',
            'https://images.unsplash.com/photo-1512453979798-5ea904acfb5a?q=80&w=1000',
          ),
          _buildActivityCard(
            'Nightlife & Entertainment',
            'Step into the rhythm of Dubai\'s nights at our exclusive clubs.',
            'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?q=80&w=1000', // Nightlife
          ),
          _buildActivityCard(
            'Wellness & Relaxation',
            'Unwind at our spa with a soothing massage.',
            'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?q=80&w=1000', // Spa
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String title, String desc, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(0), // Boxy
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.network(imgUrl, fit: BoxFit.cover),
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
