import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  return GoRouter(
    initialLocation: '/today',
    routes: [
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
