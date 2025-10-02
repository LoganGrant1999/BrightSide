import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Cache service for today's stories by metro and date
/// Key format: {metroId}:{yyyy-MM-dd}
class IssueCache {
  final Map<String, CachedIssue> _cache = {};
  Timer? _midnightTimer;
  final _invalidationController = StreamController<void>.broadcast();

  /// Stream that emits when cache is invalidated
  Stream<void> get onInvalidate => _invalidationController.stream;

  IssueCache() {
    _scheduleMidnightInvalidation();
  }

  /// Get cached data for a specific metro and date
  /// Returns null if cache miss or expired
  CachedIssue? get(String metroId, DateTime date) {
    final key = _buildKey(metroId, date);
    final cached = _cache[key];

    if (cached == null) {
      return null;
    }

    // Check if cached data is from the correct date
    if (!_isSameDay(cached.date, date)) {
      _cache.remove(key);
      return null;
    }

    return cached;
  }

  /// Store data in cache for a specific metro and date
  void set(String metroId, DateTime date, dynamic data) {
    final key = _buildKey(metroId, date);
    _cache[key] = CachedIssue(
      metroId: metroId,
      date: date,
      data: data,
      cachedAt: DateTime.now(),
    );
  }

  /// Check if cache has valid data for metro and date
  bool has(String metroId, DateTime date) {
    return get(metroId, date) != null;
  }

  /// Clear all cached data
  void clearAll() {
    _cache.clear();
    debugPrint('IssueCache: All cache cleared');
    _invalidationController.add(null);
  }

  /// Clear cache for a specific metro
  void clearMetro(String metroId) {
    _cache.removeWhere((key, value) => value.metroId == metroId);
    debugPrint('IssueCache: Cleared cache for metro: $metroId');
    _invalidationController.add(null);
  }

  /// Clear all cache entries that are not from today
  void clearOldEntries() {
    final today = DateTime.now();
    _cache.removeWhere((key, cached) => !_isSameDay(cached.date, today));
    debugPrint('IssueCache: Cleared old entries');
    _invalidationController.add(null);
  }

  /// Invalidate cache and notify listeners
  void invalidate() {
    clearAll();
    debugPrint('IssueCache: Cache invalidated');
  }

  /// Build cache key from metroId and date
  String _buildKey(String metroId, DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    return '$metroId:$dateStr';
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Schedule a timer to invalidate cache at midnight
  void _scheduleMidnightInvalidation() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    debugPrint(
      'IssueCache: Scheduling midnight invalidation in ${durationUntilMidnight.inHours}h ${durationUntilMidnight.inMinutes % 60}m',
    );

    _midnightTimer = Timer(durationUntilMidnight, () {
      debugPrint('IssueCache: Midnight reached, invalidating cache');
      clearOldEntries();
      // Schedule next midnight
      _scheduleMidnightInvalidation();
    });
  }

  /// Dispose resources
  void dispose() {
    _midnightTimer?.cancel();
    _invalidationController.close();
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getStats() {
    return {
      'totalEntries': _cache.length,
      'entries': _cache.keys.toList(),
      'nextInvalidation': _midnightTimer?.isActive == true
          ? 'Scheduled'
          : 'Not scheduled',
    };
  }
}

/// Cached issue data with metadata
class CachedIssue {
  final String metroId;
  final DateTime date;
  final dynamic data;
  final DateTime cachedAt;

  CachedIssue({
    required this.metroId,
    required this.date,
    required this.data,
    required this.cachedAt,
  });

  /// Check if cache entry is fresh (less than 5 minutes old)
  bool get isFresh {
    final age = DateTime.now().difference(cachedAt);
    return age.inMinutes < 5;
  }
}
