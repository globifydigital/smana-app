import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class BookingHomeView extends StatelessWidget {
  const BookingHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Section: Sea View Room Image
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1590490360182-c33d57733427?q=80&w=1000&auto=format&fit=crop', // Sea view
                  fit: BoxFit.cover,
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                // Booking Interface overlay
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: GlassmorphicContainer(
                    width: double.infinity,
                    height: 250,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        AppTheme.goldPrimary.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateBox('CHECK IN', '29-11-2025'),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ),
                              Expanded(
                                child: _buildDateBox('CHECK OUT', '30-11-2025'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  Icons.check_box_outline_blank,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Text(
                                'Flexible Dates',
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputBox(
                                  '1 Room, 2 Adult, 0 Child',
                                  Icons.add,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: _buildInputBox('Promo', null)),
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFC5A365,
                                ), // Muted gold/beige
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Check Rates'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bottom Cards (Facilities, Activities, Clubs)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSquareGoldCard(Icons.layers, 'Facilities', context),
                _buildSquareGoldCard(
                  Icons.iron,
                  'Activities and\nTourism',
                  context,
                ), // Burj icon approx
                _buildSquareGoldCard(Icons.apartment, 'Clubs', context),
              ],
            ),
          ),
          const SizedBox(height: 100), // Bottom padding for nav bar
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox(String text, IconData? suffix) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (suffix != null) Icon(suffix, size: 16, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildSquareGoldCard(
    IconData icon,
    String text,
    BuildContext context,
  ) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFC5A365), // Muted Gold
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
