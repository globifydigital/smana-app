import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: const Text('Offers')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xFFC5A365),
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text(
                    'Current Offers',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: const Color(0xFF1E293B),
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text(
                    'Upcoming Offers',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOfferCard(
                  'Enjoy a Luxury\nExperience',
                  'Rate starts from AED 45',
                  'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=1000',
                ),
                _buildOfferCard(
                  'Luxury Room',
                  'Get up to 50% off',
                  'https://images.unsplash.com/photo-1590490360182-c33d57733427?q=80&w=1000',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(String title, String price, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black,
              child: Text(
                price,
                style: const TextStyle(
                  color: AppTheme.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
