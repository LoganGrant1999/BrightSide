import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/core/theme/app_theme.dart';
import 'package:brightside/shared/services/app_router.dart';
import 'package:brightside/shared/services/firebase_boot.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/core/services/analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await initFirebase();

  // Log app open event
  await AnalyticsService.logAppOpen();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const BrightSideApp(),
    ),
  );
}

class BrightSideApp extends ConsumerWidget {
  const BrightSideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BrightSide',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
