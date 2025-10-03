import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/features/metro/metro.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/features/story/providers/story_providers.dart';
import 'package:brightside/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brightside/shared/services/functions_service.dart';
import 'package:brightside/core/theme/app_theme.dart';
import 'package:brightside/core/utils/ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _useDeviceLocation = false;
  int _versionTapCount = 0;

  @override
  Widget build(BuildContext context) {
    final metroState = ref.watch(metroProvider);
    final authState = ref.watch(authProvider);
    final isSignedIn = authState.isAuthenticated;
    final user = authState.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account section
          _buildSectionHeader(context, 'Account'),
          if (isSignedIn && user != null)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(user.displayName ?? user.email),
              subtitle: Text('Signed in with ${_getProviderName(user.authProvider)}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/auth/account');
              },
            )
          else
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Guest User'),
              subtitle: const Text('Sign in to save preferences across devices'),
              trailing: TextButton(
                onPressed: () {
                  context.push('/auth');
                },
                child: const Text('Sign In'),
              ),
            ),
          const Divider(),

          // Notifications section
          _buildSectionHeader(context, 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Daily digest and updates'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.push('/settings/notifications');
            },
          ),
          const Divider(),

          // Location section
          _buildSectionHeader(context, 'Location'),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Current Metro'),
            subtitle: Text(metroState.metro.toString()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showMetroSelector(context);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.my_location),
            title: const Text('Use Device Location'),
            subtitle: const Text('Automatically set metro based on your location'),
            value: _useDeviceLocation,
            onChanged: (value) async {
              if (value) {
                // Request location permission and set metro
                await ref.read(metroProvider.notifier).setFromLocation();
                setState(() {
                  _useDeviceLocation = true;
                });
                if (mounted) {
                  UIHelpers.showSuccessSnackBar(
                    context,
                    'Metro updated based on your location',
                  );
                }
              } else {
                setState(() {
                  _useDeviceLocation = false;
                });
              }
            },
          ),
          const Divider(),

          // Legal section
          _buildSectionHeader(context, 'Legal'),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Legal Information'),
            subtitle: const Text('Privacy, terms, and content policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/settings/legal');
            },
          ),
          const Divider(),

          // Developer section
          _buildSectionHeader(context, 'Developer'),
          // Debug-only: Fix seed data for current metro
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('[DEBUG] Fix seed for current metro'),
              subtitle: const Text('Bump publishedAt & ensure status=published'),
              onTap: () async {
                await _handleFixSeedForMetro(context);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
            title: const Text(
              'Delete Local Data',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            subtitle: const Text('Clear all locally stored data and preferences'),
            onTap: () {
              _showDeleteDataConfirmation(context);
            },
          ),
          const Divider(),

          // App info
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Support'),
            subtitle: const Text('Contact us for help'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _openSupportEmail(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {
              _handleVersionTap();
            },
          ),
          const SizedBox(height: AppTheme.paddingLarge),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.paddingMedium,
        AppTheme.paddingLarge,
        AppTheme.paddingMedium,
        AppTheme.paddingSmall,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showMetroSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Metro',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ...kMetros.map((metro) {
              final metroState = ref.watch(metroProvider);
              final isSelected = metro.id == metroState.metroId;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
                ),
                title: Text(metro.name),
                subtitle: Text(metro.state),
                selected: isSelected,
                onTap: () async {
                  await ref.read(metroProvider.notifier).setFromPicker(metro.id);
                  setState(() {
                    _useDeviceLocation = false;
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Handle fix seed for current metro (debug only)
  Future<void> _handleFixSeedForMetro(BuildContext context) async {
    final metroState = ref.read(metroProvider);
    final metroId = metroState.metroId;

    // TODO: Move token to a safer dev-only config or environment variable
    const devToken = 'YOUR_LONG_RANDOM_TOKEN';

    try {
      if (context.mounted) {
        UIHelpers.showInfoSnackBar(context, 'Running backfill for $metroId...');
      }

      final svc = ref.read(functionsServiceProvider);
      final count = await svc.fixSeedForMetro(
        metroId: metroId,
        token: devToken,
        limit: 25,
      );

      // Invalidate story providers to refresh
      ref.invalidate(todayStoriesProvider);
      ref.invalidate(popularStoriesProvider);

      if (context.mounted) {
        UIHelpers.showSuccessSnackBar(
          context,
          'Updated $count articles for $metroId',
        );
      }
    } catch (e) {
      if (context.mounted) {
        UIHelpers.showErrorSnackBar(context, 'Backfill failed: $e');
      }
    }
  }

  void _showDeleteDataConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Local Data'),
        content: const Text(
          'This will clear all locally stored data including:\n\n'
          '• Your metro preference\n'
          '• Story likes\n'
          '• User ID\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteLocalData();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        UIHelpers.showSuccessSnackBar(
          context,
          'Local data deleted. Please restart the app.',
          duration: const Duration(seconds: 4),
        );

        // Reset state
        setState(() {
          _useDeviceLocation = false;
        });

        // Invalidate all providers to force refresh
        ref.invalidate(metroProvider);
        ref.invalidate(storyRepositoryProvider);
        ref.invalidate(todayStoriesProvider);
        ref.invalidate(popularStoriesProvider);
        ref.invalidate(likesControllerProvider);
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.handleError(context, e);
      }
    }
  }

  String _getProviderName(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple';
      case 'email':
        return 'Email/Password';
      default:
        return provider;
    }
  }

  /// Open support email with prefilled metadata
  Future<void> _openSupportEmail(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final metroState = ref.read(metroProvider);
      final authState = ref.read(authProvider);
      final uid = authState.appUser?.uid ?? 'not-signed-in';

      final subject = Uri.encodeComponent('BrightSide Support Request');
      final body = Uri.encodeComponent(
        'Please describe your issue:\n\n\n\n'
        '---\n'
        'App Version: ${packageInfo.version}\n'
        'Build: ${packageInfo.buildNumber}\n'
        'User ID: $uid\n'
        'Metro: ${metroState.metroId}\n',
      );

      final uri = Uri.parse('mailto:support@brightside.com?subject=$subject&body=$body');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          UIHelpers.showErrorSnackBar(
            context,
            'Could not open email client',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        UIHelpers.showErrorSnackBar(
          context,
          'Error opening support email: $e',
        );
      }
    }
  }

  /// Handle version tap (7 taps triggers test crash in debug mode)
  void _handleVersionTap() {
    if (!kDebugMode) return;

    setState(() {
      _versionTapCount++;
    });

    if (_versionTapCount >= 7) {
      // Reset counter
      setState(() {
        _versionTapCount = 0;
      });

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Debug: Test Crash'),
          content: const Text(
            'This will trigger a test crash for Crashlytics. The app will restart.\n\n'
            'This only works in debug mode.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                // Trigger a test crash
                FirebaseCrashlytics.instance.crash();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red[700],
              ),
              child: const Text('Crash Now'),
            ),
          ],
        ),
      );
    } else {
      // Show tap count hint
      UIHelpers.showInfoSnackBar(
        context,
        'Tapped $_versionTapCount/7 times',
      );
    }
  }

}
