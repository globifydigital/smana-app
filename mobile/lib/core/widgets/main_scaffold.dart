import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dining/providers/cart_provider.dart';
import '../../features/dining/providers/order_provider.dart';
import '../../features/service_request/providers/service_request_provider.dart';
import 'package:mobile/features/auth/models/guest_model.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final guest = authState.guest;

    // Determine current index based on location string from GoRouter state would be ideal,
    // but for simplicity we'll just show the icons and handle taps.
    // A more robust way is to use a ShellRoute notification, but simple is better for now.

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      extendBodyBehindAppBar: true, // For transparency
      appBar: AppBar(
        title: Text(
          'Welcome, ${guest?.name.split(' ').first ?? 'Guest'}',
          style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[800],
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHx8MA%3D%3D',
              ), // Placeholder
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white70),
            onPressed: () {},
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const AppDrawer(),
      body: child, // The screen content (Home, Booking, etc)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Dark surface
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.percent_outlined),
              label: 'Offers',
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/booking')) return 1;
    if (location.startsWith('/offers')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/booking');
        break;
      case 2:
        context.go('/offers');
        break;
    }
  }
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guest = ref.watch(authProvider).guest;

    return Drawer(
      backgroundColor: AppTheme.darkBackground,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.goldPrimary,
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guest?.name ?? 'Guest',
                        style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        guest?.email ?? '',
                        style: GoogleFonts.lato(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person_outline, 'Profile', () {}),
          _buildDrawerItem(
            Icons.chat_bubble_outline,
            'Feedback',
            () => context.push('/feedback'),
          ),
          _buildDrawerItem(Icons.info_outline, 'About Us', () {}),
          _buildDrawerItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
          _buildDrawerItem(Icons.support_agent, 'Support', () {}),
          _buildDrawerItem(
            Icons.local_offer_outlined,
            'Latest Offers',
            () => context.go('/offers'),
          ),
          _buildDrawerItem(Icons.settings_outlined, 'Settings', () {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.goldPrimary),
                foregroundColor: AppTheme.goldPrimary,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                _handleLogout(context, ref, guest);
              },
              child: const Text('LOGOUT'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    WidgetRef ref,
    GuestModel? guest,
  ) async {
    // 4. Check if Guest is Checked-in
    if (guest != null && guest.isCheckedIn) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            'Checked-in Guest',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You are currently checked into Room ${guest.roomNumber}. Please check out at reception before signing out.',
            style: GoogleFonts.lato(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Okay',
                style: GoogleFonts.lato(color: AppTheme.goldPrimary),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // 1. Show Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Sign Out',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: GoogleFonts.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign Out',
              style: GoogleFonts.lato(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // 2. Execute Logout Actions
      await ref.read(authProvider.notifier).logout();

      // 2c. Reset all Riverpod providers
      // Note: In a real app we might need to list all providers or use a container reset.
      // For now, invalidating key providers.
      // Assuming imports for other providers are available or we just invalidate auth which triggers others if watched.
      // To properly invalidate specific providers like cart/orders, we need to import them.
      // For this snippet, I will just navigate to login which should be enough if providers are auto-disposed or watched.
      // But user asked to explicitly invalidate. I will do so if I can inspect imports,
      // otherwise I will just navigate.
      // Ideally MainScaffold should import these if it needs to invalidate them.
      // Let's assume we can only invalidate auth here unless we add imports.
      // However, navigating to '/login' usually resets the stack.
      ref.invalidate(cartProvider);
      ref.invalidate(orderProvider);
      ref.invalidate(serviceRequestProvider);

      // 3. User is completely logged out -> Navigate to Login
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
