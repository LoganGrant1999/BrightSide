import 'dart:math' as math;

class GeoUtils {
  GeoUtils._();

  /// Earth's radius in kilometers
  static const double earthRadiusKm = 6371.0;

  /// Calculate the distance between two points on Earth using the Haversine formula.
  ///
  /// Parameters:
  /// - [lat1], [lon1]: Latitude and longitude of the first point in degrees
  /// - [lat2], [lon2]: Latitude and longitude of the second point in degrees
  ///
  /// Returns: Distance in kilometers
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Convert degrees to radians
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final radLat1 = _degreesToRadians(lat1);
    final radLat2 = _degreesToRadians(lat2);

    // Haversine formula
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.pow(math.sin(dLon / 2), 2) *
            math.cos(radLat1) *
            math.cos(radLat2);
    final c = 2 * math.asin(math.sqrt(a));

    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
}
