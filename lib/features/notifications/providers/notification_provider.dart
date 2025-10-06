import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/user_service.dart';

// Notification state
class NotificationState {
  final bool hasPermission;
  final bool isEnabled;
  final String? currentMetro;
  final bool isLoading;

  NotificationState({
    this.hasPermission = false,
    this.isEnabled = false,
    this.currentMetro,
    this.isLoading = false,
  });

  NotificationState copyWith({
    bool? hasPermission,
    bool? isEnabled,
    String? currentMetro,
    bool? isLoading,
  }) {
    return NotificationState(
      hasPermission: hasPermission ?? this.hasPermission,
      isEnabled: isEnabled ?? this.isEnabled,
      currentMetro: currentMetro ?? this.currentMetro,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Notification notifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;
  final Ref _ref;
  final UserService _userService;

  NotificationNotifier(this._ref, {
    NotificationService? service,
    UserService? userService,
  })  : _service = service ?? NotificationService(),
        _userService = userService ?? UserService(),
        super(NotificationState()) {
    _init();
  }

  Future<void> _init() async {
    // Check initial permission status
    final hasPermission = await _service.hasPermission();
    state = state.copyWith(hasPermission: hasPermission);

    // Get user's notification opt-in preference
    final authState = _ref.read(authProvider);
    if (authState.appUser != null) {
      state = state.copyWith(
        isEnabled: authState.appUser!.notificationOptIn,
        currentMetro: authState.appUser!.chosenMetro,
      );
    }
  }

  /// Request permission (should be called after first feed view)
  Future<void> requestPermission() async {
    state = state.copyWith(isLoading: true);

    final settings = await _service.requestPermission();
    final hasPermission = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    state = state.copyWith(
      hasPermission: hasPermission,
      isLoading: false,
    );

    // If permission granted, initialize FCM
    if (hasPermission) {
      await _initializeFCM();
    }
  }

  /// Toggle notifications on/off
  Future<void> toggleNotifications(bool enabled) async {
    final authState = _ref.read(authProvider);
    if (authState.appUser == null) return;

    state = state.copyWith(isLoading: true);

    try {
      // Update Firestore
      await _userService.updateNotificationOptIn(
        authState.appUser!.uid,
        enabled,
      );

      // Subscribe/unsubscribe from metro topic
      if (enabled && state.currentMetro != null) {
        await _service.subscribeToMetroTopic(state.currentMetro!);
      } else if (!enabled && state.currentMetro != null) {
        await _service.unsubscribeFromMetroTopic(state.currentMetro!);
      }

      state = state.copyWith(isEnabled: enabled, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Update metro subscription when metro changes
  Future<void> updateMetroSubscription(String newMetroId) async {
    if (!state.isEnabled || !state.hasPermission) return;

    state = state.copyWith(isLoading: true);

    try {
      // Unsubscribe from old metro
      if (state.currentMetro != null) {
        await _service.unsubscribeFromMetroTopic(state.currentMetro!);
      }

      // Subscribe to new metro
      await _service.subscribeToMetroTopic(newMetroId);

      state = state.copyWith(currentMetro: newMetroId, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  /// Initialize FCM after permission granted
  Future<void> _initializeFCM() async {
    final authState = _ref.read(authProvider);
    if (authState.appUser == null) return;

    await _service.initialize(
      userId: authState.appUser!.uid,
      onMessageReceived: _handleForegroundMessage,
      onNotificationTap: _handleNotificationTap,
    );

    // Subscribe to metro topic if enabled
    if (state.isEnabled && state.currentMetro != null) {
      await _service.subscribeToMetroTopic(state.currentMetro!);
    }
  }

  /// Handle notification tap and navigate
  void _handleNotificationTap(RemoteMessage message) {
    // Navigation will be handled by main.dart using router
    // Store the message data for the router to consume
    _pendingNotification = message;
  }

  RemoteMessage? _pendingNotification;

  /// Get and clear pending notification (called by router)
  RemoteMessage? getPendingNotification() {
    final message = _pendingNotification;
    _pendingNotification = null;
    return message;
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // Show in-app notification or update UI
    // This can be customized based on your needs
  }

  /// Clean up on sign out
  Future<void> cleanupOnSignOut(String userId) async {
    await _service.deleteDeviceToken(userId);
    state = NotificationState();
  }
}

// Notification provider
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});
