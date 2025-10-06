import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightside/features/story/model/story.dart';
import 'package:brightside/features/story/data/story_repository.dart';
import 'package:brightside/core/constants/api_constants.dart';

/// HTTP implementation of StoryRepository using Dio
class HttpStoryRepository implements StoryRepository {
  static const String _userIdKey = 'http_user_id';

  final Dio _dio;
  final SharedPreferences _prefs;
  late final String _userId;

  HttpStoryRepository(this._prefs)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            sendTimeout: ApiConstants.sendTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _userId = _prefs.getString(_userIdKey) ?? _generateUserId();
    _setupInterceptors();
  }

  @override
  String get userId => _userId;

  String _generateUserId() {
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    _prefs.setString(_userIdKey, userId);
    return userId;
  }

  /// Setup Dio interceptors for logging and retries
  void _setupInterceptors() {
    // Logging interceptor (only in debug/dev mode)
    if (!kReleaseMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) {
            debugPrint('[HTTP] $obj');
          },
        ),
      );
    }

    // Retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          // Retry logic for network errors and 5xx server errors
          if (_shouldRetry(error)) {
            final retryCount = error.requestOptions.extra['retryCount'] ?? 0;

            if (retryCount < ApiConstants.maxRetries) {
              // Wait before retrying
              await Future.delayed(
                ApiConstants.retryDelay * (retryCount + 1),
              );

              // Increment retry count
              error.requestOptions.extra['retryCount'] = retryCount + 1;

              // Retry the request
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Add userId to all requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-User-Id'] = _userId;
          return handler.next(options);
        },
      ),
    );
  }

  /// Determine if request should be retried
  bool _shouldRetry(DioException error) {
    // Retry on network errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on 5xx server errors
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      if (statusCode != null && statusCode >= 500 && statusCode < 600) {
        return true;
      }
    }

    return false;
  }

  @override
  Future<List<Story>> fetchToday(String metroId) async {
    try {
      final response = await _dio.get(
        ApiConstants.todayEndpoint,
        queryParameters: {'metroId': metroId},
      );

      final data = response.data as List;
      return data.map((json) => Story.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<Story>> fetchPopular(String metroId) async {
    try {
      final response = await _dio.get(
        ApiConstants.popularEndpoint,
        queryParameters: {'metroId': metroId},
      );

      final data = response.data as List;
      return data.map((json) => Story.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Story?> getById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.storiesEndpoint}/$id');

      if (response.data == null) {
        return null;
      }

      return Story.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e);
    }
  }

  @override
  Future<int> like(String storyId, String userId) async {
    try {
      final endpoint = ApiConstants.likeEndpoint.replaceAll('{id}', storyId);
      final response = await _dio.post(
        endpoint,
        data: {'userId': userId},
      );

      // Expect response to contain updated like count
      return response.data['likesCount'] as int;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> submitUserStory(Story draft) async {
    try {
      await _dio.post(
        ApiConstants.submitEndpoint,
        data: draft.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Convert DioException to user-friendly error messages
  Exception _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    }

    if (error.type == DioExceptionType.connectionError) {
      if (error.error is SocketException) {
        return Exception('No internet connection. Please try again later.');
      }
      return Exception('Failed to connect to server. Please try again later.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] as String?;

      switch (statusCode) {
        case 400:
          return Exception(message ?? 'Invalid request. Please check your input.');
        case 401:
          return Exception('Unauthorized. Please sign in again.');
        case 403:
          return Exception('Access forbidden.');
        case 404:
          return Exception('Resource not found.');
        case 429:
          return Exception('Too many requests. Please try again later.');
        case 500:
          return Exception('Server error. Please try again later.');
        case 503:
          return Exception('Service unavailable. Please try again later.');
        default:
          return Exception(message ?? 'An unexpected error occurred.');
      }
    }

    return Exception('An unexpected error occurred: ${error.message}');
  }
}
