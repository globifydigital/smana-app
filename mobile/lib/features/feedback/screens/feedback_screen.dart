import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(title: const Text('Give Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name',
                style: TextStyle(color: AppTheme.goldPrimary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                width: double.infinity,
                child: const Text(
                  'Widle Studio',
                  style: TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Contact Number',
                style: TextStyle(color: AppTheme.goldPrimary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                width: double.infinity,
                child: const Text(
                  '+91 00000 00000',
                  style: TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Email Address',
                style: TextStyle(color: AppTheme.goldPrimary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                width: double.infinity,
                child: const Text(
                  'xyz123@gmail.com',
                  style: TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Share your experience in scaling',
                style: TextStyle(color: AppTheme.goldPrimary, fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Emojis Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildEmoji(Icons.sentiment_very_dissatisfied, 'Worst', true),
                  _buildEmoji(Icons.sentiment_dissatisfied, 'Not Good', false),
                  _buildEmoji(Icons.sentiment_neutral, 'Fine', false),
                  _buildEmoji(Icons.sentiment_satisfied, 'Look Good', false),
                  _buildEmoji(
                    Icons.sentiment_very_satisfied,
                    'Very Good',
                    false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: 0.2,
                onChanged: (v) {},
                activeColor: const Color(0xFFFCD34D),
                inactiveColor: Colors.white24,
              ),

              const SizedBox(height: 24),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Add your comments...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5A365),
                  ),
                  child: const Text('SUBMIT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmoji(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFFFCD34D) : Colors.grey,
          size: 30,
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}
