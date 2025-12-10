import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Hide status bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _navigateToNext();
  }

  @override
  void dispose() {
    // Restore status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    // 3 seconds delay
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Forcing Onboarding to show as requested by User for verification.
    // In production, you might want to uncomment the check.
    // final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    const isFirstTime = true;

    if (isFirstTime) {
      // Do not set isFirstTime to false here.
      // It should be set after the user completes onboarding.
      if (mounted) context.go('/onboarding');
    } else {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center Logo
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset(
                'assets/images/smana_logo.png',
                fit: BoxFit.contain,
              ),
            ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),

            const SizedBox(height: 30),

            // SMANA
            Text(
              'SMANA',
              style: GoogleFonts.lato(
                fontSize: 32,
                fontWeight: FontWeight.bold, // Bold
                color: Colors.white,
                letterSpacing: 4.0,
              ),
            ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0),

            const SizedBox(height: 8),

            // Hotel Al Raffa
            Text(
              'Hotel Al Raffa',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w300, // Light
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 3.0,
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
