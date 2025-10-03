import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/location_provider.dart';

class MetroPickerPage extends ConsumerWidget {
  const MetroPickerPage({super.key});

  static const _supportedMetros = [
    {'id': 'slc', 'name': 'Salt Lake City', 'state': 'Utah'},
    {'id': 'nyc', 'name': 'New York City', 'state': 'New York'},
    {'id': 'gsp', 'name': 'Greenville-Spartanburg', 'state': 'South Carolina'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding/location'),
        ),
        title: const Text('Choose Your Metro'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Select your metro area',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll see positive news from this community',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _supportedMetros.length,
                  itemBuilder: (context, index) {
                    final metro = _supportedMetros[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          child: Icon(
                            Icons.location_city,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(
                          metro['name']!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        subtitle: Text(metro['state']!),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          // Save metro selection
                          await ref
                              .read(metroStateProvider.notifier)
                              .setMetro(metro['id']!);

                          if (!context.mounted) return;
                          // Proceed to auth (will be implemented in next prompt)
                          context.go('/onboarding/auth');
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
