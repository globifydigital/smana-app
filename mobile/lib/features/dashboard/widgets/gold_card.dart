import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../../core/theme/app_theme.dart';

class GoldCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const GoldCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            AppTheme.goldPrimary.withOpacity(0.1),
            AppTheme.goldPrimary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            AppTheme.goldPrimary.withOpacity(0.5),
            AppTheme.goldPrimary.withOpacity(0.1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppTheme.goldPrimary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
