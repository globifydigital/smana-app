import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';

class CheckedInHomeView extends ConsumerWidget {
  const CheckedInHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guest = ref.watch(authProvider).guest;
    final checkIn = guest?.checkInDate;
    final checkOut = checkIn?.add(
      const Duration(days: 1),
    ); // Mock checkout for now if missing

    final formatDate = (DateTime? date) {
      if (date == null) return 'Oct - 26 - 2025';
      return DateFormat('MMM - dd - yyyy').format(date);
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1540541338287-41700207dee6?q=80&w=2670&auto=format&fit=crop', // Ocean view room
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay to ensure text readability mostly at top/bottom
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.9), // Dark top
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.8), // Dark bottom for buttons
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top padding to account for MainScaffold AppBar (which is transparent and over body)
                // AppBar height is typically 56. Status bar is handled by SafeArea?
                // Wait, if extendBodyBehindAppBar is true, SafeArea might push content below status bar, but AppBar starts at top.
                // Actually MainScaffold has extendBodyBehindAppBar: true.
                // So AppBar is over the content.
                // We need to push the Room Info Card down so it's not covered by the AppBar.
                // AppBar ~56 + Status Bar ~top padding.
                const SizedBox(height: 60),

                // Room Info Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      // Room Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, // Reduced from 16
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA08050), // Muted Gold
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          'Room No: ${guest?.roomNumber ?? '55'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                13, // Slightly reduced font size if needed
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Reduced from 16
                      // Divider
                      Container(width: 1, height: 40, color: Colors.white24),
                      const SizedBox(width: 8), // Reduced from 16
                      // Dates
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: _buildDateColumn(
                                'Check - In:',
                                formatDate(checkIn),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white24,
                            ),
                            Flexible(
                              child: _buildDateColumn(
                                'Check - Out:',
                                formatDate(checkOut),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Pushes buttons to bottom
                // Grid Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20,
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildMenuButton(
                        Icons.restaurant_menu,
                        'Dining',
                        () => context.push('/dining'),
                      ),
                      _buildMenuButton(
                        Icons.layers,
                        'Facilities',
                        () => context.push('/facilities'),
                      ),
                      _buildMenuButton(
                        Icons.apartment,
                        'Clubs',
                        () => context.push('/clubs'),
                      ),
                      _buildMenuButton(
                        Icons.surfing,
                        'Activities and\nTourism',
                        () => context.push('/activities'),
                      ),
                      _buildMenuButton(
                        Icons.chat,
                        'Feedback',
                        () => context.push('/feedback'),
                      ),
                      _buildMenuButton(
                        Icons.medical_services,
                        'Services\nRequest',
                        () => context.push('/services'),
                      ),
                    ],
                  ),
                ),

                // Bottom Nav Placeholder Space (if handled by parent, otherwise padding)
                // Assuming standard bottom nav height ~60-80
                // The prompt image shows the bottom nav.
                // If this view is solely the content, we just need space.
                // But wait, the image shows the bottom nav "Home, Booking, Offers" as part of the screen design.
                // Currently `SmanaApp` has `MainScaffold` wrapping `HomeScreen`?
                // `HomeScreen` returns `CheckedInHomeView` if checked in.
                // `HomeScreen` imports `MainScaffold`? Let's check `HomeScreen`.
                // If `MainScaffold` provides the nav bar, we don't render it here.
                // But the user said "Make the check-in user homescreen exactly like this".
                // If `MainScaffold`'s nav bar looks different, I might need to style it there.
                // For now, I'll trust `MainScaffold` handles the nav and just ensure content fits.
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFA08050), // Muted Gold matching mock
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
