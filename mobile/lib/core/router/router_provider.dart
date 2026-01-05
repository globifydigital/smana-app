import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/main_scaffold.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/dining/screens/dining_screen.dart';
import '../../features/facilities/screens/facilities_screen.dart';
import '../../features/activities/screens/activities_screen.dart';
import '../../features/clubs/screens/clubs_screen.dart';
import '../../features/offers/screens/offers_screen.dart';
import '../../features/feedback/screens/feedback_screen.dart';
import '../../features/service_request/screens/service_request_screen.dart';
import '../../features/dining/screens/cart_screen.dart';
import '../../features/dining/screens/orders_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/offers',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: MainScaffold(child: const OffersScreen()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/dining',
        builder: (context, state) => const DiningScreen(),
      ),
      GoRoute(
        path: '/facilities',
        builder: (context, state) => const FacilitiesScreen(),
      ),
      GoRoute(
        path: '/activities',
        builder: (context, state) => const ActivitiesScreen(),
      ),
      GoRoute(path: '/clubs', builder: (context, state) => const ClubsScreen()),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServiceRequestScreen(),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/orders',
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          final initialTab = tab == 'previous' ? 1 : 0;
          return OrdersScreen(initialTab: initialTab);
        },
      ),
    ],
  );
});
