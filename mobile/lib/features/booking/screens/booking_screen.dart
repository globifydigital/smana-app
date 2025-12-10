import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This screen is shown when guest is registered but NOT checked in.
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 80,
                color: AppTheme.goldPrimary.withOpacity(0.5),
              ),
              const SizedBox(height: 32),
              Text(
                'Reservation Confirmed',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to SMANA Hotel Al Raffa.\nPlease proceed to the reception desk to complete your check-in and unlock the full guest experience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.goldPrimary),
                    foregroundColor: AppTheme.goldPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Maybe show QR code or booking details
                  },
                  child: const Text('VIEW BOOKING DETAILS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
