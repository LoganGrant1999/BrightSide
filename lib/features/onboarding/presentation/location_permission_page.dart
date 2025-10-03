import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/location_provider.dart';

class LocationPermissionPage extends ConsumerWidget {
  const LocationPermissionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/intro'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: locationState.when(
            data: (permission) {
              // If we have permission and metro is detected, navigate forward
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Icon(
                    Icons.location_on,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enable Location',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We use your location to show you positive news from your local community.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: () async {
                      final result = await ref
                          .read(locationPermissionProvider.notifier)
                          .requestPermission();

                      if (!context.mounted) return;

                      if (result.isGranted) {
                        // Try to detect metro from location
                        final metro = await ref
                            .read(locationPermissionProvider.notifier)
                            .detectMetroFromLocation();

                        if (!context.mounted) return;

                        if (metro != null) {
                          // Save metro and proceed to auth
                          await ref
                              .read(metroStateProvider.notifier)
                              .setMetro(metro);

                          if (!context.mounted) return;
                          context.go('/onboarding/auth');
                        } else {
                          // Location granted but no supported metro nearby
                          context.go('/onboarding/metro');
                        }
                      } else {
                        // Permission denied, show metro picker
                        context.go('/onboarding/metro');
                      }
                    },
                    child: const Text('Allow Location Access'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/onboarding/metro'),
                    child: const Text('Choose Manually'),
                  ),
                  const Spacer(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/onboarding/metro'),
                    child: const Text('Choose Metro Manually'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
