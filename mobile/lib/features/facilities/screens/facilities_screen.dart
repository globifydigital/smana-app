import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: const Text('Facilities')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
        children: [
          _buildFacilityCard(
            'Rooms & Suites',
            'https://images.unsplash.com/photo-1611892440504-42a792e24d32?q=80&w=1000',
          ),
          _buildFacilityCard(
            '24-Hour Security',
            'https://images.unsplash.com/photo-1557597774-9d273605dfa9?q=80&w=1000',
          ),
          _buildFacilityCard(
            'Fitness Center',
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1000',
          ),
          _buildFacilityCard(
            'Swimming Pool',
            'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?q=80&w=1000',
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(String title, String imgUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.center,
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(12),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
