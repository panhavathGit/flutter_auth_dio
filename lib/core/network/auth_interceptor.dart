import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import '../../features/auth/data/models/http/auth_response.dart';
import '../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _dio; // Pass Dio to retry requests

  AuthInterceptor(this._storageService, this._dio);

  // @override
  // void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
  //   // 1. Always use Access Token for requests
  //   final token = await _storageService.getAccessToken();

  //   if (token != null) {
  //     options.headers['Authorization'] = 'Bearer $token';
  //   }
  //   handler.next(options);
  // }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Always use Access Token for requests
    final token = await _storageService.getAccessToken();

    AppLogger.d('🔑 Token: $token');
    AppLogger.d('🌐 Request URL: ${options.uri}');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Prevent infinite loop
      if (err.requestOptions.path.contains('refresh') ||
          err.requestOptions.path.contains('logout')) {
        await _storageService.clearAll();
        handler.next(err);
        return; // fix this return statement
      }

      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          // 1. Call refresh endpoint to get new tokens
          final response = await _dio.post(
            'customer/api/v1/auth/token',
            data: {'refreshToken': refreshToken},
          );

          // 2. Parse new tokens
          final authResponse = AuthResponse.fromJson(response.data);

          // 3. Save new tokens to storage
          await _storageService.saveAccessToken(authResponse.accessToken);
          await _storageService.saveRefreshToken(authResponse.refreshToken);

          // 4. Retry original request with new token
          err.requestOptions.headers['Authorization'] =
              'Bearer ${authResponse.accessToken}';
          final retryResponse = await _dio.fetch(err.requestOptions);

          return handler.resolve(retryResponse); // return retried response
        } catch (e) {
          // 5. Refresh failed → force logout
          AppLogger.e('Refresh token failed: $e');
          await _storageService.clearAll();
          handler.next(err);
          return;
        }
      }
    }

    handler.next(err); // pass all other errors through
  }
}
