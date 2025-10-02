import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/features/story/model/story.dart';

abstract class StoryRepository {
  Future<List<Story>> fetchToday(String metroId);
  Future<List<Story>> fetchPopular(String metroId);
  Future<Story?> getById(String id);
  Future<int> like(String storyId, String userId);
  Future<void> submitUserStory(Story draft);
  String get userId;
}

class MockStoryRepository implements StoryRepository {
  static const String _likesKey = 'story_likes';
  static const String _userIdKey = 'mock_user_id';

  final SharedPreferences _prefs;
  late final String _userId;
  final List<Story> _mockStories;
  final List<Story> _userSubmittedStories = [];

  MockStoryRepository(this._prefs) : _mockStories = _generateMockStories() {
    _userId = _prefs.getString(_userIdKey) ?? _generateUserId();
  }

  @override
  String get userId => _userId;

  String _generateUserId() {
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _prefs.setString(_userIdKey, userId);
    return userId;
  }

  // Generate deterministic sample data
  static List<Story> _generateMockStories() {
    final now = DateTime.now();

    return [
      // SLC Stories
      Story(
        id: 'slc_1',
        metroId: 'slc',
        type: StoryType.original,
        title: 'New Ski Resort Opens in Big Cottonwood Canyon',
        subhead: 'World-class slopes ready for winter season',
        body: 'A brand new ski resort featuring 50 runs and state-of-the-art lifts opened today in Big Cottonwood Canyon. The resort promises to bring more accessibility to Utah\'s famous powder.',
        imageUrl: 'https://picsum.photos/seed/slc1/800/600',
        sourceLinks: ['https://example.com/ski-resort'],
        likesCount: 45,
        createdAt: now.subtract(const Duration(hours: 2)),
        publishedAt: now.subtract(const Duration(hours: 2)),
        status: StoryStatus.published,
      ),
      Story(
        id: 'slc_2',
        metroId: 'slc',
        type: StoryType.summaryLink,
        title: 'Utah Tech Startup Raises \$50M Series B',
        subhead: 'AI company focused on climate solutions',
        body: 'Local startup ClimateAI announced their Series B funding round led by top Silicon Valley investors. The company plans to expand their team by 100 employees.',
        imageUrl: 'https://picsum.photos/seed/slc2/800/600',
        sourceLinks: [
          'https://example.com/tech-news',
          'https://example.com/funding-round',
        ],
        likesCount: 32,
        createdAt: now.subtract(const Duration(hours: 5)),
        publishedAt: now.subtract(const Duration(hours: 5)),
        status: StoryStatus.published,
      ),
      Story(
        id: 'slc_3',
        metroId: 'slc',
        type: StoryType.user,
        title: 'Great New Coffee Shop Downtown',
        body: 'Just discovered this amazing coffee shop on 300 South. Their pour-over is incredible and the atmosphere is perfect for remote work.',
        likesCount: 18,
        createdAt: now.subtract(const Duration(hours: 8)),
        publishedAt: now.subtract(const Duration(hours: 8)),
        status: StoryStatus.published,
      ),

      // NYC Stories
      Story(
        id: 'nyc_1',
        metroId: 'nyc',
        type: StoryType.original,
        title: 'Brooklyn Bridge Gets Major Renovation',
        subhead: 'Historic landmark to undergo \$500M restoration',
        body: 'The iconic Brooklyn Bridge will receive its most comprehensive restoration in decades. Work will focus on structural integrity while preserving the bridge\'s historic character.',
        imageUrl: 'https://picsum.photos/seed/nyc1/800/600',
        sourceLinks: ['https://example.com/brooklyn-bridge'],
        likesCount: 203,
        createdAt: now.subtract(const Duration(hours: 1)),
        publishedAt: now.subtract(const Duration(hours: 1)),
        status: StoryStatus.published,
      ),
      Story(
        id: 'nyc_2',
        metroId: 'nyc',
        type: StoryType.summaryLink,
        title: 'New Subway Line Opening in Queens',
        subhead: 'Commute times expected to drop by 30 minutes',
        body: 'The MTA announced the opening of a new subway line connecting Queens to Manhattan, significantly reducing travel time for thousands of daily commuters.',
        imageUrl: 'https://picsum.photos/seed/nyc2/800/600',
        sourceLinks: ['https://example.com/mta-news'],
        likesCount: 156,
        createdAt: now.subtract(const Duration(hours: 3)),
        publishedAt: now.subtract(const Duration(hours: 3)),
        status: StoryStatus.published,
      ),
      Story(
        id: 'nyc_3',
        metroId: 'nyc',
        type: StoryType.user,
        title: 'Best Pizza in Williamsburg',
        body: 'After trying every pizza place in the area, I can confirm that Joe\'s on Bedford Ave has the best slice. Don\'t sleep on their grandma pizza!',
        likesCount: 89,
        createdAt: now.subtract(const Duration(hours: 6)),
        publishedAt: now.subtract(const Duration(hours: 6)),
        status: StoryStatus.published,
      ),

      // GSP Stories
      Story(
        id: 'gsp_1',
        metroId: 'gsp',
        type: StoryType.original,
        title: 'Downtown Greenville Adds New Park',
        subhead: '15-acre green space opens to public',
        body: 'A new urban park featuring walking trails, playgrounds, and event spaces opened in downtown Greenville. The park is part of the city\'s green initiative.',
        imageUrl: 'https://picsum.photos/seed/gsp1/800/600',
        sourceLinks: ['https://example.com/greenville-parks'],
        likesCount: 67,
        createdAt: now.subtract(const Duration(hours: 4)),
        publishedAt: now.subtract(const Duration(hours: 4)),
        status: StoryStatus.published,
      ),
      Story(
        id: 'gsp_2',
        metroId: 'gsp',
        type: StoryType.summaryLink,
        title: 'BMW Manufacturing Plant Expansion',
        subhead: 'Company to add 1,000 jobs in Spartanburg',
        body: 'BMW announced a major expansion of their Spartanburg manufacturing facility, making it one of the largest automotive plants in North America.',
        imageUrl: 'https://picsum.photos/seed/gsp2/800/600',
        sourceLinks: [
          'https://example.com/bmw-news',
          'https://example.com/sc-jobs',
        ],
        likesCount: 54,
        createdAt: now.subtract(const Duration(hours: 7)),
        publishedAt: now.subtract(const Duration(hours: 7)),
        status: StoryStatus.published,
      ),
      Story(
        id: 'gsp_3',
        metroId: 'gsp',
        type: StoryType.user,
        title: 'Hidden Hiking Trail Near Travelers Rest',
        body: 'Found this amazing trail off Highway 25. About 3 miles roundtrip with a beautiful waterfall at the end. Not crowded at all!',
        likesCount: 41,
        createdAt: now.subtract(const Duration(hours: 10)),
        publishedAt: now.subtract(const Duration(hours: 10)),
        status: StoryStatus.published,
      ),
    ];
  }

  @override
  Future<List<Story>> fetchToday(String metroId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Filter by metro and published today
    final allStories = [..._mockStories, ..._userSubmittedStories];
    final filtered = allStories.where((story) {
      final isCorrectMetro = story.metroId == metroId;
      final isPublished = story.status == StoryStatus.published;
      final isToday = story.publishedAt != null &&
                      story.publishedAt!.isAfter(todayStart);
      return isCorrectMetro && isPublished && isToday;
    }).toList();

    // Sort by published date (newest first)
    filtered.sort((a, b) => b.publishedAt!.compareTo(a.publishedAt!));

    // Apply likes from storage
    return _applyLikesFromStorage(filtered);
  }

  @override
  Future<List<Story>> fetchPopular(String metroId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter by metro and published status
    final allStories = [..._mockStories, ..._userSubmittedStories];
    final filtered = allStories.where((story) {
      return story.metroId == metroId && story.status == StoryStatus.published;
    }).toList();

    // Sort by likes count (descending)
    filtered.sort((a, b) => b.likesCount.compareTo(a.likesCount));

    // Apply likes from storage
    return _applyLikesFromStorage(filtered);
  }

  @override
  Future<Story?> getById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final allStories = [..._mockStories, ..._userSubmittedStories];
    try {
      final story = allStories.firstWhere((s) => s.id == id);
      final withLikes = await _applyLikesFromStorage([story]);
      return withLikes.first;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> like(String storyId, String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Get current likes map
    final likesMap = _getLikesMap();

    // Toggle like for this user and story
    final userLikes = likesMap[userId] ?? <String>{};

    if (userLikes.contains(storyId)) {
      // Unlike
      userLikes.remove(storyId);
    } else {
      // Like
      userLikes.add(storyId);
    }

    likesMap[userId] = userLikes;

    // Save to shared preferences
    await _saveLikesMap(likesMap);

    // Calculate total likes for this story
    int totalLikes = 0;
    for (final likes in likesMap.values) {
      if (likes.contains(storyId)) {
        totalLikes++;
      }
    }

    // Update story in mock data
    final allStories = [..._mockStories, ..._userSubmittedStories];
    final storyIndex = allStories.indexWhere((s) => s.id == storyId);
    if (storyIndex != -1) {
      final originalLikes = allStories[storyIndex].likesCount;
      totalLikes += originalLikes;
    }

    return totalLikes;
  }

  @override
  Future<void> submitUserStory(Story draft) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, this would send to backend
    // For mock, we'll add it to our local list with published status
    final submittedStory = draft.copyWith(
      status: StoryStatus.published,
      publishedAt: DateTime.now(),
    );

    _userSubmittedStories.add(submittedStory);
  }

  // Helper methods for likes persistence
  Map<String, Set<String>> _getLikesMap() {
    final likesJson = _prefs.getString(_likesKey);
    if (likesJson == null) return {};

    try {
      final decoded = jsonDecode(likesJson) as Map<String, dynamic>;
      return decoded.map((userId, likes) {
        return MapEntry(userId, Set<String>.from(likes as List));
      });
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveLikesMap(Map<String, Set<String>> likesMap) async {
    final toSave = likesMap.map((userId, likes) {
      return MapEntry(userId, likes.toList());
    });
    await _prefs.setString(_likesKey, jsonEncode(toSave));
  }

  Future<List<Story>> _applyLikesFromStorage(List<Story> stories) async {
    final likesMap = _getLikesMap();

    return stories.map((story) {
      // Count total likes for this story from all users
      int additionalLikes = 0;
      for (final likes in likesMap.values) {
        if (likes.contains(story.id)) {
          additionalLikes++;
        }
      }

      return story.copyWith(
        likesCount: story.likesCount + additionalLikes,
      );
    }).toList();
  }

  // Helper to check if current user liked a story
  bool hasUserLiked(String storyId) {
    final likesMap = _getLikesMap();
    final userLikes = likesMap[_userId] ?? <String>{};
    return userLikes.contains(storyId);
  }
}
