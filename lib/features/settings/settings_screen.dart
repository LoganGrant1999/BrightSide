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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:brightside/env/app_env.dart';
import 'package:brightside/core/services/system_config.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _useDeviceLocation = false;
  int _versionTapCount = 0;
  SystemConfig _systemConfig = SystemConfig.defaultConfig;
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadSystemConfig();
    _loadVersionInfo();
  }

  Future<void> _loadSystemConfig() async {
    final config = await SystemConfig.load();
    if (mounted) {
      setState(() {
        _systemConfig = config;
      });
    }
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      // If package info fails, fall back to pubspec version
      if (mounted) {
        setState(() {
          _appVersion = '1.0.0';
          _buildNumber = '1';
        });
      }
    }
  }

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

          // Developer section (only in dev mode, never in release)
          if (!Env.isProd && !kReleaseMode) ...[
            _buildSectionHeader(context, 'Developer'),
            // Admin Portal (admins only)
            if (isSignedIn)
              FutureBuilder<bool>(
                future: _checkIsAdmin(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Admin Portal'),
                      subtitle: const Text('Content moderation & management'),
                      trailing: const Icon(Icons.open_in_new, size: 16),
                      onTap: () {
                        _openAdminPortal();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            // Debug-only: Fix seed data for current metro
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('[DEBUG] Fix seed for current metro'),
              subtitle: const Text('Bump publishedAt & ensure status=published'),
              onTap: () async {
                await _handleFixSeedForMetro(context);
              },
            ),
            // Health indicators
            _buildHealthIndicators(),
            // Test notification
            ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.orange),
              title: const Text('Send test notification'),
              subtitle: const Text('Test APNs/FCM delivery to this device'),
              onTap: () => _handleSendTestNotification(context, ref),
            ),
          ],
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
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () async {
              final uri = Uri.parse(_systemConfig.privacyPolicyUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  UIHelpers.showErrorSnackBar(
                    context,
                    'Could not open privacy policy',
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () async {
              final uri = Uri.parse(_systemConfig.termsOfServiceUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  UIHelpers.showErrorSnackBar(
                    context,
                    'Could not open terms of service',
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: Text(
              _appVersion.isNotEmpty
                ? '$_appVersion (Build $_buildNumber)'
                : 'Loading...',
            ),
            onTap: () {
              _handleVersionTap();
            },
          ),
          const SizedBox(height: AppTheme.paddingLarge),

          // Account section
          if (authState.isAuthenticated) ...[
            _buildSectionHeader(context, 'Account'),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              subtitle: const Text('Permanently delete your account and all data'),
              onTap: () {
                _showDeleteAccountConfirmation(context);
              },
            ),
            const SizedBox(height: AppTheme.paddingLarge),
          ],
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

  Future<void> _handleSendTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      if (context.mounted) {
        UIHelpers.showInfoSnackBar(context, 'Sending test notification...');
      }

      final functions = ref.read(functionsServiceProvider);
      final result = await functions.sendTestPush();

      if (context.mounted) {
        final message = result['message'] ?? 'Test notification sent';
        final successCount = result['successCount'] ?? 0;
        final failureCount = result['failureCount'] ?? 0;

        if (successCount > 0) {
          UIHelpers.showSuccessSnackBar(
            context,
            '$message ($successCount sent, $failureCount failed)',
          );
        } else {
          UIHelpers.showErrorSnackBar(
            context,
            'No devices registered. Grant notification permission first.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        UIHelpers.showErrorSnackBar(
          context,
          'Failed to send test notification: ${e.toString()}',
        );
      }
    }
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete:\n\n'
          '• Your account\n'
          '• All your submissions\n'
          '• All your story likes\n'
          '• All associated data\n\n'
          'This action CANNOT be undone. You will be signed out immediately.',
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
              await _deleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // Show loading indicator
      if (mounted) {
        UIHelpers.showInfoSnackBar(context, 'Deleting account...');
      }

      // Call Cloud Function to delete account
      final callable = FirebaseFunctions.instance.httpsCallable('deleteAccount');
      await callable.call();

      // Sign out
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        // Show success message
        UIHelpers.showSuccessSnackBar(
          context,
          'Account deleted successfully',
          duration: const Duration(seconds: 3),
        );

        // Navigate to Today tab
        context.go('/today');
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackBar(
          context,
          'Failed to delete account: ${e.toString()}',
        );
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

  /// Handle version tap (7 taps triggers test crash in dev/debug only, never in release)
  void _handleVersionTap() {
    // Only allow crash trigger in dev/debug mode, never in release
    if (kReleaseMode || Env.isProd) return;

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
            'This only works in dev mode.',
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

  /// Check if current user is an admin
  Future<bool> _checkIsAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final idTokenResult = await user.getIdTokenResult();
      return idTokenResult.claims?['admin'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Open admin portal in browser
  Future<void> _openAdminPortal() async {
    try {
      // TODO: Update URL to production domain when deployed
      final uri = Uri.parse('https://brightside-9a2c5.web.app/admin');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          UIHelpers.showErrorSnackBar(
            context,
            'Could not open admin portal',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackBar(
          context,
          'Error opening admin portal: $e',
        );
      }
    }
  }

  /// Build health indicators widget (debug only)
  Widget _buildHealthIndicators() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('system')
          .doc('health')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return ListTile(
            leading: const Icon(Icons.health_and_safety, color: Colors.grey),
            title: const Text('[DEBUG] System Health'),
            subtitle: const Text('No health data available'),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final metros = ['slc', 'nyc', 'gsp'];
        final dateFormat = DateFormat('MMM d, h:mm a');

        return ExpansionTile(
          leading: const Icon(Icons.health_and_safety, color: AppTheme.primaryColor),
          title: const Text('[DEBUG] System Health'),
          subtitle: const Text('Last scheduler runs'),
          children: metros.map((metroId) {
            final metroData = data[metroId] as Map<String, dynamic>?;

            String ingestTime = 'Never';
            String digestTime = 'Never';

            if (metroData != null) {
              if (metroData['lastIngestAt'] != null) {
                final timestamp = metroData['lastIngestAt'] as Timestamp;
                ingestTime = dateFormat.format(timestamp.toDate());
              }
              if (metroData['lastDigestAt'] != null) {
                final timestamp = metroData['lastDigestAt'] as Timestamp;
                digestTime = dateFormat.format(timestamp.toDate());
              }
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
                vertical: AppTheme.paddingSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metroId.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.download, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Ingest: $ingestTime',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.notifications, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Digest: $digestTime',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

}
