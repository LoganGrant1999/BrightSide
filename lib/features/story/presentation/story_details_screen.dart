import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brightside/features/story/model/story.dart';
import 'package:brightside/features/story/providers/story_providers.dart';
import 'package:brightside/core/theme/app_theme.dart';

class StoryDetailsScreen extends ConsumerWidget {
  final String storyId;

  const StoryDetailsScreen({
    super.key,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyAsync = ref.watch(storyByIdProvider(storyId));

    return Scaffold(
      body: storyAsync.when(
        data: (story) {
          if (story == null) {
            return _buildNotFoundState(context);
          }
          return _buildStoryContent(context, ref, story);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(
          context,
          error.toString(),
          () {
            ref.invalidate(storyByIdProvider(storyId));
          },
        ),
      ),
    );
  }

  Widget _buildStoryContent(BuildContext context, WidgetRef ref, Story story) {
    final isLiked = ref.watch(isStoryLikedProvider(story.id));
    final likesController = ref.read(likesControllerProvider.notifier);

    return CustomScrollView(
      slivers: [
        // App bar with hero image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: story.imageUrl != null
                ? CachedNetworkImage(
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
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  )
                : Container(
                    color: AppTheme.surfaceColor,
                    child: const Icon(
                      Icons.article,
                      size: 64,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
          ),
        ),

        // Story content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Story type badge
                _buildTypeBadge(story.type),
                const SizedBox(height: AppTheme.paddingMedium),

                // Title
                Text(
                  story.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppTheme.paddingMedium),

                // Subhead
                if (story.subhead != null) ...[
                  Text(
                    story.subhead!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.normal,
                        ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                ],

                // Like button and count
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await likesController.toggleLike(story.id);
                        // Invalidate to refresh the story
                        ref.invalidate(storyByIdProvider(storyId));
                      },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      label: Text('${story.likesCount}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLiked
                            ? Colors.red.withValues(alpha: 0.1)
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.paddingLarge),

                // Body content
                if (story.body != null) ...[
                  Text(
                    story.body!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                ],

                // Summary link special UI
                if (story.type == StoryType.summaryLink &&
                    story.sourceLinks.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.paddingMedium),
                  // Prominent "Read at Source" button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(story.sourceLinks.first),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Read at Source'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(AppTheme.paddingMedium),
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                ],

                // Sources list (if available and not already shown as button)
                if (story.sourceLinks.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    'Sources',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  ...story.sourceLinks.map((url) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTheme.paddingSmall,
                      ),
                      child: InkWell(
                        onTap: () => _launchUrl(url),
                        child: Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 20,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: AppTheme.paddingSmall),
                            Expanded(
                              child: Text(
                                url,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                // Metadata
                const SizedBox(height: AppTheme.paddingLarge),
                const Divider(),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'Published ${_formatDate(story.publishedAt ?? story.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(StoryType type) {
    String label;
    Color color;

    switch (type) {
      case StoryType.original:
        label = 'Original';
        color = AppTheme.primaryColor;
        break;
      case StoryType.summaryLink:
        label = 'Summary';
        color = AppTheme.secondaryColor;
        break;
      case StoryType.user:
        label = 'Community';
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Not Found'),
      ),
      body: Center(
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
              'Story not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'This story may have been removed',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
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
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
