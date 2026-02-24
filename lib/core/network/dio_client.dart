import 'package:auth_dio/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../services/storage_service.dart';

/*
1. Creates a Dio instance with AppConfig.baseUrl
2. Injects AuthInterceptor which reads tokens from StorageService
3. AuthInterceptor likely attaches Bearer tokens to requests automatically
*/

class DioClient {
  late Dio _dio;
  final StorageService _storageService;

  DioClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(_storageService));
  }

  Dio get dio => _dio;
}