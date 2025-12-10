import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/gold_card.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guest = ref.watch(authProvider).guest;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'SMANA',
          style: GoogleFonts.cinzel(
            color: AppTheme.goldPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppTheme.goldPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.darkBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    guest?.name ?? 'Guest',
                    style: const TextStyle(
                      color: AppTheme.goldPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Room ${guest?.roomNumber}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white54),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we serve you?',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  GoldCard(
                    title: 'DINING',
                    icon: Icons.restaurant_menu,
                    onTap: () {
                      // Navigate to Menu
                    },
                  ),
                  GoldCard(
                    title: 'HOUSEKEEPING',
                    icon: Icons.cleaning_services,
                    onTap: () {
                      // Request cleaning
                    },
                  ),
                  GoldCard(
                    title: 'LAUNDRY',
                    icon: Icons.local_laundry_service,
                    onTap: () {},
                  ),
                  GoldCard(title: 'SPA & POOL', icon: Icons.spa, onTap: () {}),
                  GoldCard(
                    title: 'CONCIERGE',
                    icon: Icons.support_agent,
                    onTap: () {},
                  ),
                  GoldCard(
                    title: 'MY BILL',
                    icon: Icons.receipt_long,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
