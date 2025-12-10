import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/router_provider.dart';

class SmanaApp extends ConsumerWidget {
  const SmanaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We do NOT watch authProvider here to avoid rebuilding GoRouter on state changes.
    // final authState = ref.watch(authProvider);

    // We watch routerProvider to get the router instance.
    // Since provider creates it only once (unless dependencies change), it is stable.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SMANA Hotel Al Raffa',
      theme: AppTheme.luxuryTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
