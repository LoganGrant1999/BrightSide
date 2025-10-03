import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_provider.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final authState = ref.watch(authProvider);
    final isSignedIn = authState.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Daily Digest',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Receive a daily notification at 7:00 AM local time with today\'s positive stories from your metro area.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Permission status
          if (!isSignedIn)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Sign in to enable notifications',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (!notificationState.hasPermission)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[700]),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Permission Required',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Allow notifications to receive daily updates about positive news in your area.',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: notificationState.isLoading
                        ? null
                        : () async {
                            await ref
                                .read(notificationProvider.notifier)
                                .requestPermission();
                          },
                    icon: const Icon(Icons.notifications),
                    label: const Text('Enable Notifications'),
                  ),
                ],
              ),
            )
          else
            // Notification toggle
            SwitchListTile(
              value: notificationState.isEnabled,
              onChanged: notificationState.isLoading
                  ? null
                  : (value) async {
                      try {
                        await ref
                            .read(notificationProvider.notifier)
                            .toggleNotifications(value);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Notifications enabled'
                                    : 'Notifications disabled',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              title: const Text('Daily Digest'),
              subtitle: Text(
                notificationState.isEnabled
                    ? 'You\'ll receive notifications at 7:00 AM'
                    : 'Turn on to receive daily updates',
              ),
              secondary: Icon(
                notificationState.isEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: notificationState.isEnabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),

          const Divider(),

          // Metro info
          if (isSignedIn && notificationState.currentMetro != null)
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Notification Area'),
              subtitle: Text(_getMetroName(notificationState.currentMetro!)),
              trailing: const Icon(Icons.info_outline, size: 20),
            ),

          const SizedBox(height: 16),

          // Additional info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildInfoItem(
                  '• Notifications are sent once per day at 7:00 AM',
                ),
                _buildInfoItem(
                  '• You\'ll receive up to 5 positive stories from your metro area',
                ),
                _buildInfoItem(
                  '• Tap a notification to view the full story',
                ),
                _buildInfoItem(
                  '• You can disable notifications anytime',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  String _getMetroName(String metroId) {
    switch (metroId) {
      case 'slc':
        return 'Salt Lake City';
      case 'nyc':
        return 'New York City';
      case 'gsp':
        return 'Greenville-Spartanburg';
      default:
        return metroId;
    }
  }
}
