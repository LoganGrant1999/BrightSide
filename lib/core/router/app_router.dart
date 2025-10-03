import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/presentation/onboarding_intro_page.dart';
import '../../features/onboarding/presentation/location_permission_page.dart';
import '../../features/onboarding/presentation/metro_picker_page.dart';
import '../../features/onboarding/presentation/auth_placeholder_page.dart';
import '../../features/onboarding/providers/onboarding_state_provider.dart';

// Helper class to notify GoRouter when onboarding state changes
class _OnboardingRefreshNotifier extends ChangeNotifier {
  _OnboardingRefreshNotifier(this.ref) {
    ref.listen<OnboardingState>(
      onboardingStateProvider,
      (previous, next) {
        if (previous?.isCompleted != next.isCompleted) {
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
  // Watch onboarding state to trigger rebuilds
  final onboardingState = ref.watch(onboardingStateProvider);

  return GoRouter(
    initialLocation: '/today',
    refreshListenable: _OnboardingRefreshNotifier(ref),
    redirect: (context, state) {
      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');

      // If onboarding not completed and not already on onboarding, redirect
      if (!onboardingState.isCompleted && !isOnboardingRoute) {
        return '/onboarding/intro';
      }

      // If onboarding completed and trying to access onboarding, redirect to today
      if (onboardingState.isCompleted && isOnboardingRoute) {
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
    ],
  );
});
