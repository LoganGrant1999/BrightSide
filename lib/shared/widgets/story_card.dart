import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:brightside/features/story/model/story.dart';
import 'package:brightside/features/story/providers/story_providers.dart';
import 'package:brightside/core/theme/app_theme.dart';
import 'package:brightside/core/utils/ui.dart';

export 'package:brightside/features/story/providers/story_providers.dart' show LikeBlockedFeaturedException;

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

class StoryCard extends ConsumerStatefulWidget {
  final Story story;

  const StoryCard({
    super.key,
    required this.story,
  });

  @override
  ConsumerState<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends ConsumerState<StoryCard> {
  bool _isLiking = false;

  @override
  Widget build(BuildContext context) {
    // Get live story data for real-time like counts
    final liveStory = ref.watch(storyByIdProvider(widget.story.id)).maybeWhen(
          data: (s) => s,
          orElse: () => widget.story,
        );

    final isLiked = ref.watch(isStoryLikedProvider(widget.story.id));
    final likesController = ref.read(likesControllerProvider.notifier);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/story/${widget.story.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (widget.story.imageUrl != null)
              Semantics(
                label: 'Story image for ${widget.story.title}',
                image: true,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: widget.story.imageUrl!,
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
                  _buildTypeBadge(widget.story.type),
                  const SizedBox(height: AppTheme.paddingSmall),

                  // Title
                  Text(
                    widget.story.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subhead
                  if (widget.story.subhead != null) ...[
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      widget.story.subhead!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppTheme.paddingMedium),

                  // Source and time metadata
                  Row(
                    children: [
                      if (widget.story.sourceName != null) ...[
                        Icon(
                          Icons.public,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.story.sourceName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (widget.story.publishedAt != null) ...[
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(widget.story.publishedAt!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: AppTheme.paddingMedium),

                  // Actions row (like button and count)
                  Row(
                    children: [
                      // Like button with larger tap target
                      Semantics(
                        button: true,
                        label: isLiked ? 'Unlike story' : 'Like story',
                        hint: '${liveStory?.likesCount ?? widget.story.likesCount} likes',
                        child: InkWell(
                          onTap: _isLiking
                              ? null
                              : () async {
                                  setState(() => _isLiking = true);

                                  try {
                                    await likesController.toggleLike(widget.story.id);
                                    // Invalidate the story providers to refresh counts
                                    ref.invalidate(todayStoriesProvider);
                                    ref.invalidate(popularStoriesProvider);
                                  } catch (e) {
                                    if (e is LikeBlockedFeaturedException) {
                                      if (mounted) {
                                        UIHelpers.showInfoSnackBar(
                                          context,
                                          'Already featured — likes are paused.',
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        UIHelpers.showErrorSnackBar(
                                          context,
                                          'Failed to like story',
                                        );
                                      }
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLiking = false);
                                    }
                                  }
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
                                if (_isLiking)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: isLiked ? Colors.red : AppTheme.textSecondaryColor,
                                    size: 20,
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  '${liveStory?.likesCount ?? widget.story.likesCount}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Source links indicator
                      if (widget.story.sourceLinks.isNotEmpty)
                        Semantics(
                          label: '${widget.story.sourceLinks.length} source links',
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 16,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.story.sourceLinks.length}',
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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
