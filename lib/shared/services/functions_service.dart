import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for calling Firebase Cloud Functions
class FunctionsService {
  FunctionsService(this._functions);
  final FirebaseFunctions _functions;

  /// Admin-only: Fix seed data for a metro
  /// Requires admin token for authentication
  Future<int> fixSeedForMetro({
    required String metroId,
    required String token,
    int limit = 25,
  }) async {
    final callable = _functions.httpsCallable('fixSeedForMetro');
    final res = await callable.call({
      'metroId': metroId,
      'limit': limit,
      'token': token,
    });
    final map = res.data as Map;
    return (map['updatedCount'] as num).toInt();
  }
}

/// Provider for FunctionsService
final functionsServiceProvider = Provider<FunctionsService>((ref) {
  return FunctionsService(FirebaseFunctions.instance);
});
