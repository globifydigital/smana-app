import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Changed from room
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120, // Increased size for visibility
                  height: 120,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/smana_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'LOGIN',
                  style: GoogleFonts.cinzel(
                    fontSize: 32,
                    color: AppTheme.goldPrimary,
                  ),
                ),
                const SizedBox(height: 48),

                // Fields
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address'),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v!.isEmpty || !v.contains('@')
                      ? 'Valid email required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 32),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              print('LoginScreen: Awaiting login result...');
                              final success = await ref
                                  .read(authProvider.notifier)
                                  .login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );

                              print(
                                'LoginScreen: Login returned. Success=$success, Mounted=${context.mounted}',
                              );

                              if (success) {
                                if (context.mounted) {
                                  print(
                                    'LoginScreen: Context mounted. GOING TO /home',
                                  );
                                  context.go('/home');
                                } else {
                                  print(
                                    'LoginScreen: Context NOT mounted. Cannot navigate.',
                                  );
                                }
                              } else {
                                print(
                                  'LoginScreen: Login failed (success=false).',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ref.read(authProvider).error ??
                                            'Login failed',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    child: authState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('LOGIN'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text(
                    'New here? Create an Account',
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
