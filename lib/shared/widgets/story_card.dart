import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:brightside/features/story/model/story.dart';
import 'package:brightside/features/story/providers/story_providers.dart';
import 'package:brightside/core/theme/app_theme.dart';

/// Shimmer loading skeleton for StoryCard
class StoryCardSkeleton extends StatefulWidget {
  const StoryCardSkeleton({super.key});

  @override
  State<StoryCardSkeleton> createState() => _StoryCardSkeletonState();
}

class _StoryCardSkeletonState extends State<StoryCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppTheme.surfaceColor,
                        AppTheme.surfaceColor.withValues(alpha: 0.5),
                        AppTheme.surfaceColor,
                      ],
                      stops: [
                        _animation.value - 0.3,
                        _animation.value,
                        _animation.value + 0.3,
                      ].map((v) => v.clamp(0.0, 1.0)).toList(),
                    ),
                  ),
                ),
              ),
              // Content placeholder
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge placeholder
                    _buildShimmerBox(60, 20, _animation.value),
                    const SizedBox(height: AppTheme.paddingSmall),
                    // Title placeholder
                    _buildShimmerBox(double.infinity, 20, _animation.value),
                    const SizedBox(height: 6),
                    _buildShimmerBox(250, 20, _animation.value),
                    const SizedBox(height: AppTheme.paddingSmall),
                    // Subhead placeholder
                    _buildShimmerBox(double.infinity, 16, _animation.value),
                    _buildShimmerBox(180, 16, _animation.value + 0.1),
                    const SizedBox(height: AppTheme.paddingMedium),
                    // Actions placeholder
                    Row(
                      children: [
                        _buildShimmerBox(60, 24, _animation.value),
                        const Spacer(),
                        _buildShimmerBox(40, 16, _animation.value + 0.2),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, double shimmerValue) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppTheme.surfaceColor,
            AppTheme.surfaceColor.withValues(alpha: 0.5),
            AppTheme.surfaceColor,
          ],
          stops: [
            shimmerValue - 0.3,
            shimmerValue,
            shimmerValue + 0.3,
          ].map((v) => v.clamp(0.0, 1.0)).toList(),
        ),
      ),
    );
  }
}

/// Shimmer loading list - shows multiple skeleton cards
class StoryListSkeleton extends StatelessWidget {
  final int itemCount;

  const StoryListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const StoryCardSkeleton();
      },
    );
  }
}

class StoryCard extends ConsumerWidget {
  final Story story;

  const StoryCard({
    super.key,
    required this.story,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(isStoryLikedProvider(story.id));
    final likesController = ref.read(likesControllerProvider.notifier);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/story/${story.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (story.imageUrl != null)
              Semantics(
                label: 'Story image for ${story.title}',
                image: true,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: story.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppTheme.surfaceColor,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Story type badge
                  _buildTypeBadge(story.type),
                  const SizedBox(height: AppTheme.paddingSmall),

                  // Title
                  Text(
                    story.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subhead
                  if (story.subhead != null) ...[
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      story.subhead!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppTheme.paddingMedium),

                  // Actions row (like button and count)
                  Row(
                    children: [
                      // Like button with larger tap target
                      Semantics(
                        button: true,
                        label: isLiked ? 'Unlike story' : 'Like story',
                        hint: '${story.likesCount} likes',
                        child: InkWell(
                          onTap: () async {
                            await likesController.toggleLike(story.id);
                            // Invalidate the story providers to refresh counts
                            ref.invalidate(todayStoriesProvider);
                            ref.invalidate(popularStoriesProvider);
                          },
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.paddingSmall,
                              vertical: AppTheme.paddingSmall,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : AppTheme.textSecondaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${story.likesCount}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Source links indicator
                      if (story.sourceLinks.isNotEmpty)
                        Semantics(
                          label: '${story.sourceLinks.length} source links',
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 16,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${story.sourceLinks.length}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(StoryType type) {
    String label;
    String semanticLabel;
    Color color;

    switch (type) {
      case StoryType.original:
        label = 'BrightSide Original';
        semanticLabel = 'BrightSide Original Story';
        color = AppTheme.primaryColor;
        break;
      case StoryType.summaryLink:
        label = 'From the web (summary)';
        semanticLabel = 'Web summary story';
        color = AppTheme.secondaryColor;
        break;
      case StoryType.user:
        label = 'User Story';
        semanticLabel = 'Community submitted story';
        color = Colors.orange;
        break;
    }

    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingSmall,
          vertical: AppTheme.paddingXSmall,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
