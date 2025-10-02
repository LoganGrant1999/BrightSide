import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brightside/features/story/model/story.dart';
import 'package:brightside/features/story/data/story_repository.dart';
import 'package:brightside/features/story/data/http_story_repository.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'package:brightside/shared/services/issue_cache.dart';
import 'package:brightside/core/config/environment.dart';

// Issue cache provider
final issueCacheProvider = Provider<IssueCache>((ref) {
  final cache = IssueCache();
  ref.onDispose(() => cache.dispose());
  return cache;
});

// Story repository provider (environment-driven)
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  // Switch between Mock and HTTP repository based on environment
  if (Environment.current.useMockRepositories) {
    return MockStoryRepository(prefs);
  } else {
    return HttpStoryRepository(prefs);
  }
});

// Today stories provider (family - takes metroId as parameter)
final todayStoriesProvider = FutureProvider.family<List<Story>, String>((ref, metroId) async {
  final cache = ref.watch(issueCacheProvider);
  final repository = ref.watch(storyRepositoryProvider);
  final today = DateTime.now();

  // Check cache first
  final cached = cache.get(metroId, today);
  if (cached != null && cached.isFresh) {
    return cached.data as List<Story>;
  }

  // Fetch from repository
  final stories = await repository.fetchToday(metroId);

  // Store in cache
  cache.set(metroId, today, stories);

  return stories;
});

// Popular stories provider (family - takes metroId as parameter)
final popularStoriesProvider = FutureProvider.family<List<Story>, String>((ref, metroId) async {
  final repository = ref.watch(storyRepositoryProvider);
  return repository.fetchPopular(metroId);
});

// Story by ID provider (family - takes storyId as parameter)
final storyByIdProvider = FutureProvider.family<Story?, String>((ref, storyId) async {
  final repository = ref.watch(storyRepositoryProvider);
  return repository.getById(storyId);
});

// Likes controller state notifier
class LikesController extends StateNotifier<Map<String, bool>> {
  final StoryRepository _repository;
  final String _userId;

  LikesController(this._repository, this._userId) : super({});

  /// Toggle like for a story
  /// Returns the new like count for the story
  Future<int> toggleLike(String storyId) async {
    // Optimistically update UI
    final currentLikedState = state[storyId] ?? false;
    state = {
      ...state,
      storyId: !currentLikedState,
    };

    try {
      // Call repository to persist the like
      final newLikeCount = await _repository.like(storyId, _userId);
      return newLikeCount;
    } catch (e) {
      // Revert on error
      state = {
        ...state,
        storyId: currentLikedState,
      };
      rethrow;
    }
  }

  /// Check if a story is liked by current user
  bool isLiked(String storyId) {
    return state[storyId] ?? false;
  }

  /// Initialize liked state for a story
  void setLiked(String storyId, bool isLiked) {
    if (state[storyId] != isLiked) {
      state = {
        ...state,
        storyId: isLiked,
      };
    }
  }

  /// Load initial liked state from repository
  void loadLikedState(String storyId, bool isLiked) {
    state = {
      ...state,
      storyId: isLiked,
    };
  }
}

// Likes controller provider
final likesControllerProvider = StateNotifierProvider<LikesController, Map<String, bool>>((ref) {
  final repository = ref.watch(storyRepositoryProvider);
  final userId = repository.userId;

  return LikesController(repository, userId);
});

// Helper provider to check if a specific story is liked
final isStoryLikedProvider = Provider.family<bool, String>((ref, storyId) {
  final likesState = ref.watch(likesControllerProvider);
  return likesState[storyId] ?? false;
});
