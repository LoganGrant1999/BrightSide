import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/features/today/today_screen.dart';
import 'package:brightside/features/popular/popular_screen.dart';
import 'package:brightside/features/submit/submit_screen.dart';
import 'package:brightside/features/settings/settings_screen.dart';
import 'package:brightside/features/settings/legal_page.dart';
import 'package:brightside/features/story/presentation/story_details_screen.dart';


// Scaffold with bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/today');
              break;
            case 1:
              context.go('/submit');
              break;
            case 2:
              context.go('/popular');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Submit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Popular',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/today',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(
            currentIndex: navigationShell.currentIndex,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                name: 'today',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TodayScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/submit',
                name: 'submit',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SubmitScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/popular',
                name: 'popular',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PopularScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      // Deep link for story details
      GoRoute(
        path: '/story/:id',
        name: 'story',
        builder: (context, state) {
          final storyId = state.pathParameters['id'] ?? '';
          return StoryDetailsScreen(storyId: storyId);
        },
      ),
      // Legal page
      GoRoute(
        path: '/settings/legal',
        name: 'legal',
        builder: (context, state) => const LegalPage(),
      ),
    ],
  );
});
