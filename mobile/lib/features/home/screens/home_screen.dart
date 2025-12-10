import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/main_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/booking_home_view.dart';
import 'widgets/checked_in_home_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guest = ref.watch(authProvider).guest;
    final isCheckedIn = guest?.isCheckedIn ?? false;

    return MainScaffold(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: isCheckedIn
            ? const CheckedInHomeView()
            : const BookingHomeView(),
      ),
    );
  }
}
