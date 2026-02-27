import 'package:auth_dio/core/config/api_config.dart';
import 'package:dio/dio.dart';
import '../services/storage_service.dart';
import '../../features/auth/data/models/http/auth_response.dart';
import '../utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _dio; // Pass Dio to retry requests

  AuthInterceptor(this._storageService, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Every request does these bellow 2 steps
    final token = await _storageService.getAccessToken(); // 1. reads token from StorageService

    AppLogger.d('🔑 Token: $token');
    AppLogger.d('🌐 Request URL: ${options.uri}');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token'; // 2. attaches 'Authorization: Bearer eyJ...' to header
    }
    handler.next(options);
  }

  // runs when server returns error
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 (Unauthorized)
    if (err.response?.statusCode == 401) {
      
      // CHANGE 1: Explicitly check for 'login' and 'token' paths.
      // We don't want to try and refresh a token if the user just typed the wrong password
      // or if the Refresh Token itself is what caused the 401.
      final path = err.requestOptions.path;
      if (path.contains('auth/token') || path.contains('login')) {
        AppLogger.w('401 occurred on Auth path. Clearing storage and failing.');
        await _storageService.clearAll();
        return handler.next(err); 
      }

      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          AppLogger.i('Access Token expired. Attempting refresh...');

          // CHANGE 2: Create a "Clean" Dio instance.
          // Why? If we use 'this._dio', it will trigger the 'onRequest' above,
          // which would attach the EXPIRED access token to the header of the refresh call.
          // This "Clean" instance has no interceptors attached.
          final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));

          // 1. Call refresh endpoint
          final response = await refreshDio.post(
            ApiConfig.refreshToken,
            data: {'refreshToken': refreshToken},
          );
          
          // 2. Parse new tokens
          final authResponse = AuthResponse.fromJson(response.data);

          // 3. Save new tokens to storage
          await _storageService.saveAccessToken(authResponse.accessToken);
          await _storageService.saveRefreshToken(authResponse.refreshToken);

          // CHANGE 3: Update the original request's header.
          // We must manually overwrite the old 'Authorization' header with the brand new token.
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer ${authResponse.accessToken}';

          // CHANGE 4: Retry the original request using the main Dio instance.
          // handler.resolve() tells Dio "Ignore the error, here is the new successful response."
          final retryResponse = await _dio.fetch(requestOptions);
          return handler.resolve(retryResponse); 

        } catch (e) {
          // 5. Refresh failed (Refresh Token might be expired too)
          AppLogger.e('Refresh token failed: $e');
          await _storageService.clearAll();
          return handler.next(err);
        }
      }
    }

    return handler.next(err); // Pass all other errors (404, 500, etc.) through normally
  }


  // runs when server returns error
  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) async {
  //   if (err.response?.statusCode == 401) {
  //     // Prevent infinite loop
  //     if (err.requestOptions.path.contains('refresh') ||
  //         err.requestOptions.path.contains('logout')) {
  //       await _storageService.clearAll();
  //       handler.next(err);
  //       return; // fix this return statement
  //     }

  //     final refreshToken = await _storageService.getRefreshToken();
  //     if (refreshToken != null) {
  //       try {
  //         // 1. Call refresh endpoint to get new tokens
  //         final response = await _dio.post(
  //           'customer/api/v1/auth/token',
  //           data: {'refreshToken': refreshToken},
  //         );

  //         // 2. Parse new tokens
  //         final authResponse = AuthResponse.fromJson(response.data);

  //         // 3. Save new tokens to storage
  //         await _storageService.saveAccessToken(authResponse.accessToken);
  //         await _storageService.saveRefreshToken(authResponse.refreshToken);

  //         // 4. Retry original request with new token
  //         err.requestOptions.headers['Authorization'] =
  //             'Bearer ${authResponse.accessToken}';
  //         final retryResponse = await _dio.fetch(err.requestOptions);

  //         return handler.resolve(retryResponse); // return retried response
  //       } catch (e) {
  //         // 5. Refresh failed → force logout
  //         AppLogger.e('Refresh token failed: $e');
  //         await _storageService.clearAll();
  //         handler.next(err);
  //         return;
  //       }
  //     }
  //   }

  //   handler.next(err); // pass all other errors through
  // }
}
