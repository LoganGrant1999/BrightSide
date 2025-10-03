import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../data/metro_persistence_service.dart';
import 'onboarding_state_provider.dart';

// Location permission state
class LocationPermissionState {
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;

  LocationPermissionState({
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
  });

  factory LocationPermissionState.initial() {
    return LocationPermissionState(
      isGranted: false,
      isDenied: false,
      isPermanentlyDenied: false,
    );
  }
}

// Location permission provider
class LocationPermissionNotifier
    extends StateNotifier<AsyncValue<LocationPermissionState>> {
  LocationPermissionNotifier() : super(const AsyncValue.loading()) {
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      state = AsyncValue.data(
        LocationPermissionState(
          isGranted: permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse,
          isDenied: permission == LocationPermission.denied,
          isPermanentlyDenied: permission == LocationPermission.deniedForever,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<LocationPermissionState> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      final newState = LocationPermissionState(
        isGranted: permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse,
        isDenied: permission == LocationPermission.denied,
        isPermanentlyDenied: permission == LocationPermission.deniedForever,
      );
      state = AsyncValue.data(newState);
      return newState;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Detect metro from current location
  Future<String?> detectMetroFromLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );

      // Supported metros with coordinates
      final metros = [
        {
          'id': 'slc',
          'lat': 40.7608,
          'lng': -111.8910,
          'radius': 80.0
        }, // 80km radius
        {
          'id': 'nyc',
          'lat': 40.7128,
          'lng': -74.0060,
          'radius': 80.0
        }, // 80km radius
        {
          'id': 'gsp',
          'lat': 34.8526,
          'lng': -82.3940,
          'radius': 80.0
        }, // 80km radius
      ];

      // Find nearest metro within radius
      String? nearestMetro;
      double nearestDistance = double.infinity;

      for (final metro in metros) {
        final distance = _calculateDistance(
          position.latitude,
          position.longitude,
          metro['lat'] as double,
          metro['lng'] as double,
        );

        if (distance < (metro['radius'] as double) &&
            distance < nearestDistance) {
          nearestDistance = distance;
          nearestMetro = metro['id'] as String;
        }
      }

      return nearestMetro;
    } catch (e) {
      // If location fails, return null
      return null;
    }
  }

  // Haversine formula to calculate distance between two coordinates
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}

final locationPermissionProvider = StateNotifierProvider<
    LocationPermissionNotifier, AsyncValue<LocationPermissionState>>((ref) {
  return LocationPermissionNotifier();
});

// Metro state provider
class MetroState {
  final String? metroId;
  final bool isPersisted;

  MetroState({
    this.metroId,
    this.isPersisted = false,
  });
}

class MetroStateNotifier extends StateNotifier<MetroState> {
  final Ref ref;
  final _persistence = MetroPersistenceService();

  MetroStateNotifier(this.ref) : super(MetroState()) {
    _loadMetro();
  }

  Future<void> _loadMetro() async {
    final localMetro = await _persistence.loadMetroFromLocal();
    if (localMetro != null) {
      state = MetroState(metroId: localMetro, isPersisted: true);
    }
  }

  Future<void> setMetro(String metroId) async {
    state = MetroState(metroId: metroId, isPersisted: false);
    await _persistMetro(metroId);
    state = MetroState(metroId: metroId, isPersisted: true);

    // Mark metro as chosen in onboarding state
    ref.read(onboardingStateProvider.notifier).markMetroChosen();
  }

  Future<void> _persistMetro(String metroId) async {
    // Save to local storage (will backfill to Firestore on sign-in)
    await _persistence.saveMetroToLocal(metroId);

    // TODO: In Prompt 2, check if user is signed in and save to Firestore
    // final user = ref.read(authStateProvider).user;
    // if (user != null) {
    //   await _persistence.saveMetroToFirestore(user.uid, metroId);
    // }
  }
}

final metroStateProvider =
    StateNotifierProvider<MetroStateNotifier, MetroState>((ref) {
  return MetroStateNotifier(ref);
});
