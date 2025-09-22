import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class NetworkService {
  final Dio _dio;
  final Logger _logger = Logger();
  
  NetworkService(this._dio) {
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.options.connectTimeout = AppConstants.connectionTimeout;
    _dio.options.receiveTimeout = AppConstants.connectionTimeout;
    _dio.options.sendTimeout = AppConstants.connectionTimeout;
    
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => _logger.d(obj),
      ),
    );
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) {
          _logger.e('Network error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }
  
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  NetworkException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout',
          NetworkErrorType.timeout,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        if (statusCode >= 400 && statusCode < 500) {
          return NetworkException(
            'Client error: ${error.response?.statusMessage}',
            NetworkErrorType.clientError,
            statusCode: statusCode,
          );
        } else if (statusCode >= 500) {
          return NetworkException(
            'Server error: ${error.response?.statusMessage}',
            NetworkErrorType.serverError,
            statusCode: statusCode,
          );
        }
        break;
      
      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection',
          NetworkErrorType.noConnection,
        );
      
      case DioExceptionType.cancel:
        return NetworkException(
          'Request cancelled',
          NetworkErrorType.cancelled,
        );
      
      default:
        return NetworkException(
          'Unknown error: ${error.message}',
          NetworkErrorType.unknown,
        );
    }
    
    return NetworkException(
      'Unknown error: ${error.message}',
      NetworkErrorType.unknown,
    );
  }
  
  Future<bool> checkServerHealth(String serverAddress) async {
    try {
      final response = await get('http://$serverAddress/health');
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Health check failed: $e');
      return false;
    }
  }
}

class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;
  final int? statusCode;
  
  NetworkException(this.message, this.type, {this.statusCode});
  
  @override
  String toString() => 'NetworkException: $message';
}

enum NetworkErrorType {
  timeout,
  noConnection,
  serverError,
  clientError,
  cancelled,
  unknown,
}