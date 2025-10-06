import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/features/auth/providers/auth_provider.dart';
import 'package:brightside/features/metro/metro_provider.dart';
import 'notification_provider.dart';
import '../services/notification_service.dart';

/// Tracks whether we've asked for notification permission
class NotificationSoftAskState {
  final bool hasAskedPermission;
  final bool hasSeenFirstFeed;

  const NotificationSoftAskState({
    this.hasAskedPermission = false,
    this.hasSeenFirstFeed = false,
  });

  NotificationSoftAskState copyWith({
    bool? hasAskedPermission,
    bool? hasSeenFirstFeed,
  }) {
    return NotificationSoftAskState(
      hasAskedPermission: hasAskedPermission ?? this.hasAskedPermission,
      hasSeenFirstFeed: hasSeenFirstFeed ?? this.hasSeenFirstFeed,
    );
  }
}

/// Manages soft-ask notification permission flow
class NotificationSoftAskNotifier extends StateNotifier<NotificationSoftAskState> {
  final Ref _ref;
  final SharedPreferences _prefs;
  final NotificationService _notificationService;

  NotificationSoftAskNotifier(
    this._ref,
    this._prefs, {
    NotificationService? notificationService,
  })  : _notificationService = notificationService ?? NotificationService(),
        super(const NotificationSoftAskState()) {
    _loadState();
  }

  static const String _keyHasAsked = 'notification_has_asked_permission';
  static const String _keyHasSeenFeed = 'notification_has_seen_first_feed';

  /// Load saved state from SharedPreferences
  Future<void> _loadState() async {
    final hasAsked = _prefs.getBool(_keyHasAsked) ?? false;
    final hasSeenFeed = _prefs.getBool(_keyHasSeenFeed) ?? false;

    state = state.copyWith(
      hasAskedPermission: hasAsked,
      hasSeenFirstFeed: hasSeenFeed,
    );
  }

  /// Mark that user has seen the first feed
  /// This triggers the soft-ask if we haven't asked yet
  Future<void> markFirstFeedSeen() async {
    if (state.hasSeenFirstFeed) return; // Already seen

    await _prefs.setBool(_keyHasSeenFeed, true);
    state = state.copyWith(hasSeenFirstFeed: true);

    // Trigger soft-ask after a short delay (non-intrusive)
    if (!state.hasAskedPermission) {
      await Future.delayed(const Duration(seconds: 2));
      await _requestPermissionSoftly();
    }
  }

  /// Request permission in a soft, non-intrusive way
  Future<void> _requestPermissionSoftly() async {
    // Check if we already have permission (user may have granted in iOS Settings)
    final hasPermission = await _notificationService.hasPermission();
    if (hasPermission) {
      // Already have permission, no need to ask
      await _prefs.setBool(_keyHasAsked, true);
      state = state.copyWith(hasAskedPermission: true);
      await _initializeFCM();
      return;
    }

    // Request permission
    final authState = _ref.read(authProvider);
    if (authState.appUser == null) return;

    final granted = await _notificationService.requestPermissionAndSave(
      authState.appUser!.uid,
    );

    await _prefs.setBool(_keyHasAsked, true);
    state = state.copyWith(hasAskedPermission: true);

    if (granted) {
      await _initializeFCM();
    }
  }

  /// Initialize FCM after permission granted
  Future<void> _initializeFCM() async {
    final authState = _ref.read(authProvider);
    if (authState.appUser == null) return;

    // Initialize FCM via notification provider
    final notificationNotifier = _ref.read(notificationProvider.notifier);
    await notificationNotifier.requestPermission();
  }

  /// Reset state (for testing or user reset)
  Future<void> reset() async {
    await _prefs.remove(_keyHasAsked);
    await _prefs.remove(_keyHasSeenFeed);
    state = const NotificationSoftAskState();
  }
}

/// Provider for notification soft-ask state
final notificationSoftAskProvider =
    StateNotifierProvider<NotificationSoftAskNotifier, NotificationSoftAskState>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationSoftAskNotifier(ref, prefs);
  },
);
