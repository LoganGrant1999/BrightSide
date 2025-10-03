import 'package:brightside/core/utils/geo.dart';

class Metro {
  final String id;
  final String name;
  final String state;
  final String timezone; // IANA timezone identifier (e.g., 'America/Denver')
  final double? latitude;
  final double? longitude;

  const Metro({
    required this.id,
    required this.name,
    required this.state,
    required this.timezone,
    this.latitude,
    this.longitude,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Metro && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name, $state';
}

// Supported metros
const kMetros = [
  Metro(
    id: 'slc',
    name: 'Salt Lake City',
    state: 'UT',
    timezone: 'America/Denver', // Mountain Time
    latitude: 40.7608,
    longitude: -111.8910,
  ),
  Metro(
    id: 'nyc',
    name: 'New York City',
    state: 'NY',
    timezone: 'America/New_York', // Eastern Time
    latitude: 40.7128,
    longitude: -74.0060,
  ),
  Metro(
    id: 'gsp',
    name: 'Greenville-Spartanburg',
    state: 'SC',
    timezone: 'America/New_York', // Eastern Time
    latitude: 34.8526,
    longitude: -82.3940,
  ),
];

class MetroUtils {
  MetroUtils._();

  /// Find the nearest metro from [kMetros] to the given coordinates.
  /// Returns null if no metros have coordinates or if lat/lon is invalid.
  static Metro? nearestOfAllowed(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return null;

    Metro? nearest;
    double? shortestDistance;

    for (final metro in kMetros) {
      if (metro.latitude == null || metro.longitude == null) continue;

      final distance = GeoUtils.haversineDistance(
        latitude,
        longitude,
        metro.latitude!,
        metro.longitude!,
      );

      if (shortestDistance == null || distance < shortestDistance) {
        shortestDistance = distance;
        nearest = metro;
      }
    }

    return nearest;
  }
}
