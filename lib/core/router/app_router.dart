import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/presentation/onboarding_intro_page.dart';
import '../../features/onboarding/presentation/location_permission_page.dart';
import '../../features/onboarding/presentation/metro_picker_page.dart';
import '../../features/onboarding/presentation/auth_placeholder_page.dart';
import '../../features/onboarding/providers/onboarding_state_provider.dart';
import '../../features/auth/presentation/auth_gate_page.dart';
import '../../features/auth/presentation/email_auth_page.dart';
import '../../features/auth/presentation/account_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/notifications/presentation/notification_settings_page.dart';

// Helper class to notify GoRouter when onboarding or auth state changes
class _AppRefreshNotifier extends ChangeNotifier {
  _AppRefreshNotifier(this.ref) {
    ref.listen<OnboardingState>(
      onboardingStateProvider,
      (previous, next) {
        if (previous?.isCompleted != next.isCompleted) {
          notifyListeners();
        }
      },
    );

    ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated) {
          notifyListeners();
        }
      },
    );
  }

  final Ref ref;
}

// Placeholder screens - to be replaced with actual feature screens
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Today')),
    );
  }
}

class PopularScreen extends StatelessWidget {
  const PopularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Popular')),
    );
  }
}

class SubmitScreen extends StatelessWidget {
  const SubmitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Submit')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Settings')),
    );
  }
}

// Router configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  // Watch onboarding and auth state to trigger rebuilds
  final onboardingState = ref.watch(onboardingStateProvider);
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/today',
    refreshListenable: _AppRefreshNotifier(ref),
    redirect: (context, state) {
      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isAuthenticated = authState.isAuthenticated;

      // If onboarding not completed and not already on onboarding/auth, redirect
      if (!onboardingState.isCompleted && !isOnboardingRoute && !isAuthRoute) {
        return '/onboarding/intro';
      }

      // If onboarding completed but not authenticated, allow auth routes
      if (onboardingState.isCompleted &&
          !isAuthenticated &&
          !isAuthRoute &&
          !isOnboardingRoute) {
        return '/onboarding/auth';
      }

      // If authenticated and trying to access onboarding/auth, redirect to today
      if (isAuthenticated && (isOnboardingRoute || isAuthRoute)) {
        return '/today';
      }

      return null; // No redirect
    },
    routes: [
      // Onboarding routes
      GoRoute(
        path: '/onboarding/intro',
        name: 'onboarding-intro',
        builder: (context, state) => const OnboardingIntroPage(),
      ),
      GoRoute(
        path: '/onboarding/location',
        name: 'onboarding-location',
        builder: (context, state) => const LocationPermissionPage(),
      ),
      GoRoute(
        path: '/onboarding/metro',
        name: 'onboarding-metro',
        builder: (context, state) => const MetroPickerPage(),
      ),
      GoRoute(
        path: '/onboarding/auth',
        name: 'onboarding-auth',
        builder: (context, state) => const AuthPlaceholderPage(),
      ),
      // Auth routes
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthGatePage(),
      ),
      GoRoute(
        path: '/auth/email',
        name: 'auth-email',
        builder: (context, state) => const EmailAuthPage(),
      ),
      GoRoute(
        path: '/auth/account',
        name: 'auth-account',
        builder: (context, state) => const AccountPage(),
      ),
      // Main app routes
      GoRoute(
        path: '/today',
        name: 'today',
        builder: (context, state) => const TodayScreen(),
      ),
      GoRoute(
        path: '/popular',
        name: 'popular',
        builder: (context, state) => const PopularScreen(),
      ),
      GoRoute(
        path: '/submit',
        name: 'submit',
        builder: (context, state) => const SubmitScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        name: 'settings-notifications',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
    ],
  );
});
