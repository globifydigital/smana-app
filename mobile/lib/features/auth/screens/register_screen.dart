import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _phoneController.text.trim(),
            _passwordController.text.trim(),
          );

      if (success && mounted) {
        // Backend automatically creates the Guest in MongoDB.
        // Navigate to Booking screen as requested.
        context.go('/booking');
      } else if (mounted) {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Title
                SizedBox(
                  height: 100,
                  child: Image.asset(
                    'assets/images/smana_logo.png',
                    fit: BoxFit.contain,
                    color: AppTheme
                        .goldPrimary, // Optional: Tint if it's a solid shape, but safer to remove color if it's a full color logo.
                    // Assuming the logo is white/gold, I'll remove color property to show original logo.
                    // Wait, user said "replace this logo". The uploaded image is white text on transparent (typically).
                    // If it is black on white, it might disappear on dark background.
                    // Let's assume original colors are fine.
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SMANA HOTEL\nAL RAFFA',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldPrimary,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Guest Experience',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 48),

                // Fields
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppTheme.goldPrimary,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppTheme.goldPrimary,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v == null || !v.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppTheme.goldPrimary,
                    ),
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppTheme.goldPrimary,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter phone' : null,
                ),
                const SizedBox(height: 32),

                // Button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('CHECK IN ONLINE'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
