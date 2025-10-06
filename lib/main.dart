import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/core/theme/app_theme.dart';
import 'package:brightside/shared/services/app_router.dart';
import 'package:brightside/shared/services/firebase_boot.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/core/services/analytics.dart';
import 'package:brightside/features/notifications/providers/notification_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  tz.initializeTimeZones();

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

class BrightSideApp extends ConsumerStatefulWidget {
  const BrightSideApp({super.key});

  @override
  ConsumerState<BrightSideApp> createState() => _BrightSideAppState();
}

class _BrightSideAppState extends ConsumerState<BrightSideApp> {
  @override
  void initState() {
    super.initState();
    // Listen for notification taps and handle routing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationHandlers();
    });
  }

  /// Set up notification tap handlers
  void _setupNotificationHandlers() {
    final notificationNotifier = ref.read(notificationProvider.notifier);

    // Check for pending notification (from getInitialMessage or onMessageOpenedApp)
    final pendingMessage = notificationNotifier.getPendingNotification();
    if (pendingMessage != null) {
      _handleNotificationRoute(pendingMessage.data);
    }
  }

  /// Handle notification tap routing
  void _handleNotificationRoute(Map<String, dynamic> data) {
    final router = ref.read(appRouterProvider);
    final route = data['route'] as String?;
    final articleId = data['articleId'] as String?;

    // Route based on notification data
    if (route == '/article' && articleId != null && articleId.isNotEmpty) {
      // Single article push: navigate to article detail
      Future.delayed(const Duration(milliseconds: 300), () {
        router.push('/story/$articleId');
      });
    } else if (route == '/today' || route == null) {
      // Daily digest or unknown: navigate to Today tab
      router.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BrightSide',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
