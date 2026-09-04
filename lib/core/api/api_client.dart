import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper around Dio for the Host Your Tour API (routes/api.php, `v1`
/// prefix). Handles attaching the Sanctum bearer token and normalising
/// errors into [ApiException] — the two response envelopes used across the
/// API ({status, message} on Tour/Hotel/Booking/Payment endpoints vs
/// {success, message, errors} on Customer/auth endpoints) are both handled.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired/revoked server-side. Let it flow through as an
            // ApiException; AuthController listens for this via unauthorized
            // requests and signs the user out.
            unauthorizedController.add(null);
          }
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._internal();

  static const baseUrl = 'https://www.hostyourtour.com/api/v1';

  late final Dio _dio;

  /// Broadcasts once whenever a request comes back 401, so the auth layer
  /// can react (clear the stored token, bounce to login) without every
  /// screen having to check for it individually.
  final unauthorizedController = _SimpleBroadcaster<void>();

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _run(() => _dio.get(path, queryParameters: query));
    return _asMap(res);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    final res = await _run(() => _dio.post(path, data: data));
    return _asMap(res);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? data}) async {
    final res = await _run(() => _dio.put(path, data: data));
    return _asMap(res);
  }

  Future<Response> _run(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Map<String, dynamic> _asMap(Response res) {
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{'data': data};
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;

    if (body is Map) {
      final message = (body['message'] ?? body['error'])?.toString();
      final rawErrors = body['errors'];
      Map<String, List<String>>? fieldErrors;
      if (rawErrors is Map) {
        fieldErrors = rawErrors.map(
          (key, value) => MapEntry(key.toString(), (value as List).map((v) => v.toString()).toList()),
        );
      }
      if (message != null) {
        return ApiException(message, statusCode: status, fieldErrors: fieldErrors);
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('The connection timed out. Please check your internet and try again.');
      case DioExceptionType.connectionError:
        return ApiException('No internet connection.');
      default:
        return ApiException(
          status == 429
              ? 'Too many attempts. Please wait a moment and try again.'
              : 'Something went wrong. Please try again.',
          statusCode: status,
        );
    }
  }
}

/// Minimal broadcast stream helper (avoids pulling in a full event-bus
/// package for a single event).
class _SimpleBroadcaster<T> {
  final _controller = StreamController<T>.broadcast();
  Stream<T> get stream => _controller.stream;
  void add(T value) => _controller.add(value);
}
