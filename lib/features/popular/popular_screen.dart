import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/features/metro/metro.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/features/story/providers/story_providers.dart';
import 'package:brightside/shared/widgets/story_card.dart';
import 'package:brightside/core/theme/app_theme.dart';

class PopularScreen extends ConsumerWidget {
  const PopularScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metroState = ref.watch(metroProvider);
    final metroId = metroState.metroId;
    final storiesAsync = ref.watch(popularStoriesProvider(metroId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Popular in ${metroState.metro.name}'),
        actions: [
          // Metro selector button
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              _showMetroSelector(context, ref);
            },
          ),
        ],
      ),
      body: storiesAsync.when(
        data: (stories) {
          if (stories.isEmpty) {
            return _buildEmptyState(context);
          }

          // Limit to top 10
          final top10 = stories.take(10).toList();

          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate the provider to trigger a refresh
              ref.invalidate(popularStoriesProvider(metroId));
              // Wait for the new data
              await ref.read(popularStoriesProvider(metroId).future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.paddingSmall,
              ),
              itemCount: top10.length,
              itemBuilder: (context, index) {
                final rank = index + 1;
                return RankedStoryCard(
                  story: top10[index],
                  rank: rank,
                );
              },
            ),
          );
        },
        loading: () => const StoryListSkeleton(),
        error: (error, stack) => _buildErrorState(
          context,
          error.toString(),
          () {
            ref.invalidate(popularStoriesProvider(metroId));
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
            Icons.trending_up,
            size: 64,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'No popular stories yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Stories will appear here as they gain likes',
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

// Ranked story card with rank badge
class RankedStoryCard extends StatelessWidget {
  final dynamic story;
  final int rank;

  const RankedStoryCard({
    super.key,
    required this.story,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StoryCard(story: story),
        // Rank badge positioned in top-left corner
        Positioned(
          top: 16,
          left: 16,
          child: _buildRankBadge(rank),
        ),
      ],
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    Color textColor = Colors.white;

    // Special colors for top 3
    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
      textColor = Colors.black;
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // Silver
      textColor = Colors.black;
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
    } else {
      badgeColor = AppTheme.primaryColor;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
