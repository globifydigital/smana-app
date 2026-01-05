import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Easy way to book hotels with us',
      description:
          'It is a long established fact that a reader will be distracted by the readable content.',
      image:
          'https://images.unsplash.com/photo-1618773928121-c32242e63f39?q=80&w=800&auto=format&fit=crop', // Beige/Gold Bedroom
    ),
    OnboardingContent(
      title: 'Discover and find your perfect healing place',
      description:
          'It is a long established fact that a reader will be distracted by the readable content.',
      image:
          'https://images.unsplash.com/photo-1590490360182-c33d57733427?q=80&w=800&auto=format&fit=crop', // Modern Dark/Grey Bedroom
    ),
    OnboardingContent(
      title: 'Giving the best deal just for you',
      description:
          'It is a long established fact that a reader will be distracted by the readable content.',
      image:
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?q=80&w=800&auto=format&fit=crop', // Ocean/Resort View
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback for image loading
      body: Stack(
        children: [
          // PageView for Images & Text
          PageView.builder(
            controller: _pageController,
            itemCount: _contents.length,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = index == _contents.length - 1;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_contents[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingContent content) {
    return Stack(
      children: [
        // Full Screen Image
        Positioned.fill(
          child: Image.network(
            content.image,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[900],
              child: const Icon(Icons.image_not_supported, color: Colors.white),
            ),
          ),
        ),

        // Bottom White Card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicator Center Top of Card ? Or Logic suggests somewhere else?
                // Visual prompt: "Dots indicator at bottom" (of the text area usually)
                // Let's put a small handle or standard indicator.
                // Prompt: "Dots indicator at bottom" + "Bottom white card"
                // Usually dots are above the buttons.
                Align(
                  alignment: Alignment.center,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _contents.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.black,
                      dotColor: Colors.grey.shade300,
                      dotHeight: 6,
                      dotWidth: 6,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Title
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28, // Large
                    fontWeight: FontWeight.bold, // Serif Bold
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  content.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Next / Get Started
                    ElevatedButton(
                      onPressed: () {
                        if (_isLastPage) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF333333,
                        ), // Dark Grey/Black
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLastPage ? 'Get Started' : 'Next',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Safe area breathing room
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}
