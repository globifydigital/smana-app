import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  // Editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  double _rating = 5.0;
  bool _isSubmitting = false;

  // Premium Gold Color
  static const Color kPremiumGold = Color(0xFFAB8A62);

  @override
  void initState() {
    super.initState();
    final guest = ref.read(authProvider).guest;
    _nameController = TextEditingController(text: guest?.name ?? '');
    _emailController = TextEditingController(text: guest?.email ?? '');
    _phoneController = TextEditingController(text: guest?.phone ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post(
        ApiConstants.feedback,
        data: {
          'rating': _rating,
          'description': _descriptionController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Labels for the rating
  final List<String> _ratingLabels = [
    'Worst',
    'Not Good',
    'Fine',
    'Look Good',
    'Very Good',
  ];

  final List<String> _emojis = ['😫', '☹️', '😐', '😃', '😍'];

  Color _getLabelColor(int index) {
    int currentIndex = _rating.round() - 1;
    if (index == currentIndex) {
      if (index >= 4) return const Color(0xFF4DB6AC); // Teal for Very Good
      if (index >= 3) return const Color(0xFF4DB6AC);
      if (index >= 2) return kPremiumGold; // Fine
      return const Color(0xFFE57373); // Red/Orange for bad
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final guest = ref.watch(authProvider).guest;
    final int currentIndex = _rating.round() - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Text(
              "Welcome, ",
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 16),
            ),
            Text(
              guest?.name ?? "Guest",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              'https://api.dicebear.com/7.x/avataaars/png?seed=${guest?.name ?? "Guest"}',
            ),
            backgroundColor: Colors.grey[800],
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 2. "Give Feedback" with Decorative Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Divider(
                          color: kPremiumGold,
                          indent: 40,
                          endIndent: 10,
                        ),
                      ),
                      const Icon(
                        Icons.diamond_outlined,
                        color: kPremiumGold,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Give Feedback',
                        style: GoogleFonts.cinzel(
                          color: kPremiumGold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.diamond_outlined,
                        color: kPremiumGold,
                        size: 14,
                      ),
                      const Expanded(
                        child: Divider(
                          color: kPremiumGold,
                          indent: 10,
                          endIndent: 40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Card Container
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rows of fields
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabelTextField(
                                  _nameController,
                                  "Name",
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildLabelTextField(
                                  _phoneController,
                                  "Contact Number",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabelTextField(
                            _emailController,
                            "Email Address",
                          ),
                          const SizedBox(height: 32),

                          Text(
                            'Share your experience in scaling',
                            style: GoogleFonts.lato(
                              color: kPremiumGold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Emoji Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(5, (index) {
                              final bool isSelected = index == currentIndex;
                              return Column(
                                children: [
                                  AnimatedScale(
                                    scale: isSelected ? 1.2 : 0.85,
                                    duration: const Duration(milliseconds: 200),
                                    child: Opacity(
                                      opacity: isSelected ? 1.0 : 0.4,
                                      child: Text(
                                        _emojis[index],
                                        style: const TextStyle(fontSize: 36),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _ratingLabels[index],
                                    style: GoogleFonts.lato(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _getLabelColor(index),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),

                          const SizedBox(height: 24),

                          // Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: kPremiumGold,
                              inactiveTrackColor: Colors.grey[700],
                              thumbColor: const Color(0xFFFBE4C3),
                              overlayColor: kPremiumGold.withOpacity(0.2),
                              trackHeight: 4.0,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8.0,
                              ),
                            ),
                            child: Slider(
                              value: _rating,
                              min: 1.0,
                              max: 5.0,
                              divisions: 40,
                              onChanged: (value) =>
                                  setState(() => _rating = value),
                            ),
                          ),

                          // Rating Number
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kPremiumGold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: kPremiumGold.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _rating.toStringAsFixed(1),
                                style: GoogleFonts.lato(
                                  color: kPremiumGold,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Comment
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Add your comments...',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Submit
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitFeedback,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPremiumGold,
                                foregroundColor: Colors.white,
                                textStyle: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('SUBMIT'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // 4. Bottom Navigation Replica
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(Icons.home_outlined, "Home", true),
                _buildBottomNavItem(
                  Icons.assignment_outlined,
                  "Booking",
                  false,
                ),
                _buildBottomNavItem(
                  Icons.local_offer_outlined,
                  "Offers",
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    final color = isActive ? Colors.white : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }

  Widget _buildLabelTextField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            color: kPremiumGold,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
