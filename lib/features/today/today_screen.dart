import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/features/metro/metro.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/features/story/providers/story_providers.dart';
import 'package:brightside/shared/widgets/story_card.dart';
import 'package:brightside/core/theme/app_theme.dart';
import 'package:brightside/core/utils/ui.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metroState = ref.watch(metroProvider);
    final metroId = metroState.metroId;
    final storiesAsync = ref.watch(todayStoriesProvider(metroId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Today in ${metroState.metro.name}'),
        actions: [
          // Metro selector button
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              _showMetroSelector(context, ref);
            },
          ),
          // Overflow menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh') {
                _handleRefresh(ref, metroId);
                UIHelpers.showInfoSnackBar(
                  context,
                  'Cache cleared, refreshing...',
                );
              } else if (value == 'cache_stats') {
                _showCacheStats(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh Now'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cache_stats',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Cache Stats'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: storiesAsync.when(
        data: (stories) {
          if (stories.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate the provider to trigger a refresh
              ref.invalidate(todayStoriesProvider(metroId));
              // Wait for the new data
              await ref.read(todayStoriesProvider(metroId).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.paddingSmall,
              ),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                return StoryCard(story: stories[index]);
              },
            ),
          );
        },
        loading: () => const StoryListSkeleton(),
        error: (error, stack) => _buildErrorState(
          context,
          error.toString(),
          () {
            ref.invalidate(todayStoriesProvider(metroId));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'No stories today',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Check back later for new stories',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRefresh(WidgetRef ref, String metroId) {
    // Clear cache
    final cache = ref.read(issueCacheProvider);
    cache.clearAll();

    // Invalidate provider to force refetch
    ref.invalidate(todayStoriesProvider(metroId));
  }

  void _showCacheStats(BuildContext context, WidgetRef ref) {
    final cache = ref.read(issueCacheProvider);
    final stats = cache.getStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total entries: ${stats['totalEntries']}'),
            const SizedBox(height: 8),
            Text('Next invalidation: ${stats['nextInvalidation']}'),
            const SizedBox(height: 8),
            const Text('Cached keys:'),
            const SizedBox(height: 4),
            ...((stats['entries'] as List).map((key) => Text('  • $key'))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMetroSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MetroSelectorSheet(),
    );
  }
}

class MetroSelectorSheet extends ConsumerWidget {
  const MetroSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metroState = ref.watch(metroProvider);
    final currentMetroId = metroState.metroId;

    return Container(
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
            final isSelected = metro.id == currentMetroId;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
              ),
              title: Text(metro.name),
              subtitle: Text(metro.state),
              selected: isSelected,
              onTap: () async {
                await ref.read(metroProvider.notifier).setFromPicker(metro.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            );
          }),
          const SizedBox(height: AppTheme.paddingSmall),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.my_location, color: AppTheme.primaryColor),
            title: const Text('Use my location'),
            onTap: () async {
              await ref.read(metroProvider.notifier).setFromLocation();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
