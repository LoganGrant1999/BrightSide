import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.appUser;
    final firebaseUser = authState.firebaseUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: user == null || firebaseUser == null
          ? const Center(child: Text('Not signed in'))
          : ListView(
              children: [
                const SizedBox(height: 16),

                // Profile section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.person,
                            label: 'Name',
                            value: user.displayName ?? 'Not provided',
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: user.email,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.verified_user,
                            label: 'Sign-in method',
                            value: _getProviderDisplayName(user.authProvider),
                          ),
                          if (user.chosenMetro != null) ...[
                            const Divider(),
                            _InfoRow(
                              icon: Icons.location_city,
                              label: 'Metro',
                              value: _getMetroDisplayName(user.chosenMetro!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Actions section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sign out button
                      OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text(
                                  'Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await ref.read(authProvider.notifier).signOut();
                            if (context.mounted) {
                              context.go('/onboarding/intro');
                            }
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Account info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Account created: ${_formatDate(user.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  String _getProviderDisplayName(String provider) {
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

  String _getMetroDisplayName(String metroId) {
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
