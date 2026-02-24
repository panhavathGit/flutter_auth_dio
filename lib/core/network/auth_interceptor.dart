import 'package:auth_dio/core/utils/logger.dart';
import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  AuthInterceptor(this._storageService);

  // Called BEFORE every request is sent
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    AppLogger.i('REQUEST: ${options.method} ${options.path}');
    AppLogger.i('HEADERS: ${options.headers}');

    handler.next(options); // let the request continue
  }

  // Called when response comes back successfully
  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.i('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');

    handler.next(response); // let the response continue
  }

  // Called when something goes wrong
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    AppLogger.e('ERROR: ${err.response?.statusCode} ${err.requestOptions.path}');

    if (err.response?.statusCode == 401) {
      // Token expired or invalid
      await _storageService.clearToken();
      AppLogger.e('Token cleared. User needs to login again.');
    }

    handler.next(err); // let the error continue
  }
}
