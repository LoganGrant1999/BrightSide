import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/features/metro/metro.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/core/theme/app_theme.dart';

class MetroPickerDialog extends ConsumerWidget {
  final bool isDismissible;

  const MetroPickerDialog({
    super.key,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: isDismissible,
      child: AlertDialog(
        title: const Text('Choose Your Metro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select your metro area to see local stories and content.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              ...kMetros.map((metro) {
                return _buildMetroOption(context, ref, metro);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetroOption(BuildContext context, WidgetRef ref, Metro metro) {
    String description;
    IconData icon;

    switch (metro.id) {
      case 'slc':
        description = 'The Wasatch Front region of Utah';
        icon = Icons.terrain;
        break;
      case 'nyc':
        description = 'The Big Apple and surrounding boroughs';
        icon = Icons.location_city;
        break;
      case 'gsp':
        description = 'Upstate South Carolina';
        icon = Icons.park;
        break;
      default:
        description = metro.state;
        icon = Icons.location_on;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: InkWell(
        onTap: () async {
          await ref.read(metroProvider.notifier).setFromPicker(metro.id);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingSmall),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metro.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metro.state,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
