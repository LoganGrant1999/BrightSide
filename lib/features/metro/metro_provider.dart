import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/features/metro/metro.dart';

class MetroState {
  final String metroId;
  final bool isLoading;

  const MetroState({
    required this.metroId,
    this.isLoading = false,
  });

  Metro get metro => kMetros.firstWhere(
        (m) => m.id == metroId,
        orElse: () => kMetros.first,
      );

  MetroState copyWith({
    String? metroId,
    bool? isLoading,
  }) {
    return MetroState(
      metroId: metroId ?? this.metroId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MetroNotifier extends StateNotifier<MetroState> {
  static const String _storageKey = 'selected_metro_id';
  static const String _firstLaunchKey = 'has_launched_before';
  final SharedPreferences _prefs;

  MetroNotifier(this._prefs)
      : super(MetroState(
          metroId: _prefs.getString(_storageKey) ?? 'slc',
        ));

  /// Check if this is the first launch
  bool get isFirstLaunch => !(_prefs.getBool(_firstLaunchKey) ?? false);

  /// Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    await _prefs.setBool(_firstLaunchKey, true);
  }

  /// Set metro from user's current location using geolocator.
  /// Returns true if location was successfully obtained and metro set.
  /// Returns false if location was denied or unavailable.
  Future<bool> setFromLocation() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Location denied
        state = state.copyWith(isLoading: false);
        return false;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      // Find nearest metro
      final nearestMetro = MetroUtils.nearestOfAllowed(
        position.latitude,
        position.longitude,
      );

      if (nearestMetro != null) {
        await _setMetro(nearestMetro.id);
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        // No metro found
        state = state.copyWith(isLoading: false);
        return false;
      }
    } catch (e) {
      // On error
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// Set metro from user picker/selection
  Future<void> setFromPicker(String metroId) async {
    // Validate that the metro exists
    final metroExists = kMetros.any((m) => m.id == metroId);
    if (!metroExists) return;

    await _setMetro(metroId);
  }

  /// Internal method to set metro and persist to storage
  Future<void> _setMetro(String metroId) async {
    state = state.copyWith(metroId: metroId);
    await _prefs.setString(_storageKey, metroId);
  }
}

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

// Metro state provider
final metroProvider = StateNotifierProvider<MetroNotifier, MetroState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MetroNotifier(prefs);
});
