import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Singleton ApiClient for handling all HTTP requests to the backend server.
///
/// Usage:
/// ```dart
/// final apiClient = ApiClient();
/// final response = await apiClient.get('/trading/accounts');
/// ```
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  // Default base URL - can be overridden via configure()
  static const String _defaultBaseUrl = 'http://localhost:8080/';

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      validateStatus: (status) {
        // Only accept 2xx status codes as successful
        // This will throw DioException for 4xx and 5xx errors
        return status != null && status >= 200 && status < 300;
      },
    ));

    _setupInterceptors();
  }

  /// Configure the API client with custom settings
  void configure({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }
    if (connectTimeout != null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }
  }

  /// Setup interceptors for logging
  void _setupInterceptors() {
    // Request interceptor - logging only
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('🌐 REQUEST[${options.method}] => ${options.uri}');
          if (options.data != null) {
            print('📤 Data: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            print('🔍 Query: ${options.queryParameters}');
          }
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          print('📥 Data: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
          print('💥 Message: ${error.message}');
          if (error.response?.data != null) {
            print('📥 Error Data: ${error.response?.data}');
          }
        }
        return handler.next(error);
      },
    ));
  }

  /// Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Create options without Content-Type to avoid CORS preflight
      final getOptions = (options ?? Options()).copyWith(
        headers: {
          ...?options?.headers,
          'Accept': 'application/json',
        },
      );
      // Explicitly remove Content-Type header for GET requests
      getOptions.headers?.remove('Content-Type');

      debugPrint('Options Headers: ${getOptions.headers}');
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: getOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Add Content-Type for POST requests
      final postOptions = (options ?? Options()).copyWith(
        headers: {
          'Content-Type': 'application/json',
          ...?options?.headers,
        },
      );

      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: postOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Add Content-Type for PUT requests
      final putOptions = (options ?? Options()).copyWith(
        headers: {
          'Content-Type': 'application/json',
          ...?options?.headers,
        },
      );

      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: putOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Generic PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Add Content-Type for PATCH requests
      final patchOptions = (options ?? Options()).copyWith(
        headers: {
          'Content-Type': 'application/json',
          ...?options?.headers,
        },
      );

      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: patchOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle and transform DioException into ApiException
  ApiException _handleError(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        message = _extractErrorMessage(error.response?.data) ??
                  'Server error occurred. Please try again later.';
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;

      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;

      case DioExceptionType.badCertificate:
        message = 'Security certificate error.';
        break;

      case DioExceptionType.unknown:
        message = 'An unexpected error occurred. Please try again.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Try common error message fields
      return data['message'] ??
             data['error'] ??
             data['msg'] ??
             data['detail'];
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file with multipart/form-data
  Future<Response<T>> uploadFile<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
