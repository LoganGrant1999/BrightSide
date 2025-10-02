import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/core/theme/app_theme.dart';
import 'package:brightside/shared/services/app_router.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/features/auth/presentation/auth_gate.dart';
import 'package:brightside/shared/widgets/metro_picker_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  bool _hasHandledFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    // Handle first launch after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFirstLaunch();
    });
  }

  Future<void> _handleFirstLaunch() async {
    if (_hasHandledFirstLaunch) return;

    final metroNotifier = ref.read(metroProvider.notifier);

    if (metroNotifier.isFirstLaunch) {
      _hasHandledFirstLaunch = true;

      // Try to get location permission
      final locationGranted = await metroNotifier.setFromLocation();

      if (!locationGranted) {
        // Location denied or unavailable, show metro picker
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const MetroPickerDialog(isDismissible: false),
          );
        }
      }

      // Mark first launch as complete
      await metroNotifier.markFirstLaunchComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return AuthGate(
      child: MaterialApp.router(
        title: 'BrightSide',
        theme: AppTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
