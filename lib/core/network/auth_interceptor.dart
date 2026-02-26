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
  final token = await _storageService.getAccessToken();
  
  // ← add these debug lines
  AppLogger.d('🔑 Token: $token');
  AppLogger.d('🌐 Request URL: ${options.uri}');
  
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  
  handler.next(options);
}

  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) async {
  //   // 2. If we get a 401, it means the Access Token expired
  //   if (err.response?.statusCode == 401) {
  //     final refreshToken = await _storageService.getRefreshToken();

  //     if (refreshToken != null) {
  //       try {
  //         // 3. Attempt to get a new Access Token from Express
  //         final response = await _dio.post('/auth/refresh', data: {
  //           'refreshToken': refreshToken,
  //         });

  //         // 4. Map the response to our AuthResponse model
  //         final authResponse = AuthResponse.fromJson(response.data);

  //         // 5. Save the new tokens
  //         await _storageService.saveAccessToken(authResponse.accessToken);
  //         await _storageService.saveRefreshToken(authResponse.refreshToken);

  //         // 6. Retry the original request that failed
  //         err.requestOptions.headers['Authorization'] = 'Bearer ${authResponse.accessToken}';
  //         final retryResponse = await _dio.fetch(err.requestOptions);
          
  //         return handler.resolve(retryResponse);
  //       } catch (e) {
  //         // If refresh fails, then we REALLY need to log out
  //         await _storageService.clearAll();
  //       }
  //     }
  //   }
  //   handler.next(err);
  // }

    @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {

      // ✅ Prevent infinite loop — if refresh itself fails, just clear and exit
      if (err.requestOptions.path.contains('refresh') ||
          err.requestOptions.path.contains('logout')) {
        await _storageService.clearAll();
        handler.next(err);
        return;
      }

      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            'customer/api/v1/auth/refresh', // ← verify with backend
            data: {'refreshToken': refreshToken},
          );
          // ...existing code...
        } catch (e) {
          await _storageService.clearAll();
          handler.next(err);
        }
      }
    }
    handler.next(err);
  }

}